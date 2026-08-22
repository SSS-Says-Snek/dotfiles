// SpellParser.js — WHA spell parser: top-level parse() pipeline & public API.
// Composes SpellCore (primitives), SpellRing (ring detection) and
// SpellRecognition (symbol recognition) into a GlyphAST.
.import "SpellCore.js" as Core
.import "SpellRing.js" as Ring
.import "SpellRecognition.js" as Recognition

var CONFIG = Core.CONFIG;
var _stash = Core._stash;
var cleanStroke = Core.cleanStroke;
var detectRing = Ring.detectRing;
var classifyStrokes = Recognition.classifyStrokes;
var groupIntoCandidates = Recognition.groupIntoCandidates;
var recognizeCandidate = Recognition.recognizeCandidate;
var computeGlobalMetrics = Recognition.computeGlobalMetrics;

var _nextStrokeId = 1;

// ─── PARSE ─────────────────────────────────────────────────────────────────

function parse(rawStrokeArrays, sigilDict, signDict, prevRing) {
  var cleaned = [];
  for (var i = 0; i < rawStrokeArrays.length; i++) {
    // Raw strokes are immutable once drawn, so cache the cleaned result on the
    // raw array. On each new stroke only the latest stroke is actually cleaned;
    // earlier ones (and their cached arc fits) are reused — turns the per-parse
    // cleaning/fitting from O(all strokes) into O(new strokes).
    var raw = rawStrokeArrays[i];
    var c;
    if (raw && raw._clean !== undefined) {
      c = raw._clean;
    } else {
      c = cleanStroke(raw);
      if (raw) _stash(raw, '_clean', c);
    }
    if (c !== null) {
      if (c._sid === undefined) _stash(c, '_sid', _nextStrokeId++);
      cleaned.push(c);
    }
  }

  var ring = detectRing(cleaned, prevRing);

  var wasComplete = prevRing && prevRing.complete;
  var hadPrepared = prevRing && prevRing.found && !wasComplete
    && (prevRing.coverageRatio || prevRing.completeness || 0) >= CONFIG.activationMinCoverage;
  ring.activationEvent = ring.complete && !wasComplete && (!prevRing || hadPrepared);
  if (ring.found && ring.completeness === undefined)
    ring.completeness = ring.complete ? 1 : (ring.coverageRatio || 0);

  var classified = classifyStrokes(cleaned, ring);
  var candidates = groupIntoCandidates(classified.interiorStrokes, ring);

  var primarySigil = null, extraSigils = [], signs = [], unknowns = [];
  for (var i = 0; i < candidates.length; i++) {
    var rec = recognizeCandidate(candidates[i], sigilDict, signDict, ring);
    if (!rec.recognized) {
      unknowns.push({ layer: candidates[i].layer, angleDeg: candidates[i].angleDeg, bestGuess: rec.bestGuess });
    } else if (rec.kind === 'sigil') {
      if (!primarySigil) primarySigil = rec;
      else if (rec.confidence > primarySigil.confidence) {
        extraSigils.push(primarySigil);
        primarySigil = rec;
      } else extraSigils.push(rec);
    } else {
      signs.push(rec);
    }
  }

  var globalMetrics = computeGlobalMetrics(ring, primarySigil, signs);

  var warnings = [];
  if (!ring.found) warnings.push('no_ring_detected');
  else if (!ring.complete) warnings.push('ring_incomplete');
  if (extraSigils.length > 0) warnings.push('multiple_sigils_unsupported');
  if (!primarySigil && ring.found) warnings.push('missing_primary_sigil');
  if (unknowns.some(function(u) { return u.layer === 'center'; })) warnings.push('center_contamination');

  return {
    type: 'GlyphAST',
    ring: ring,
    primarySigil: primarySigil,
    unsupportedMultipleSigils: extraSigils,
    signs: signs,
    unknowns: unknowns,
    globalMetrics: globalMetrics,
    warnings: warnings,
  };
}
