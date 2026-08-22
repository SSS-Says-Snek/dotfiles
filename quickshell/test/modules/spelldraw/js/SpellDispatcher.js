// SpellDispatcher.js — Decoupled spell matching and hook dispatch

// ─── TOLERANCE DEFAULTS ─────────────────────────────────────────────────────
// Built-in fallbacks kept deliberately LOW so hand-drawn spells still fire. A
// dictionary may override these globally via a top-level "defaultTolerances"
// block, and any individual spell may override again via its own "tolerances".
// Merge order (later wins): BUILTIN → dictionary.defaultTolerances → entry.tolerances.
var BUILTIN_TOLERANCES = {
  sigilMinConfidence: 0.55,  // accept a slightly messy sigil
  signMinConfidence: 0.50,  // signs are harder; be lenient
  maxInstability: 0.70,  // only reject genuinely chaotic casts
  equiangularToleranceDeg: 22,    // spacing slop for auto equiangular checks
  directionToleranceDeg: 35,    // +/- error for directionZone / directionAngle
};

function mergeTolerances(dictionary, entry) {
  var tol = {};
  var k;
  for (k in BUILTIN_TOLERANCES)
    if (BUILTIN_TOLERANCES.hasOwnProperty(k)) tol[k] = BUILTIN_TOLERANCES[k];
  if (dictionary && dictionary.defaultTolerances)
    for (k in dictionary.defaultTolerances)
      if (dictionary.defaultTolerances.hasOwnProperty(k)) tol[k] = dictionary.defaultTolerances[k];
  if (entry && entry.tolerances)
    for (k in entry.tolerances)
      if (entry.tolerances.hasOwnProperty(k)) tol[k] = entry.tolerances[k];
  return tol;
}

// ─── ANGLE UTILS ────────────────────────────────────────────────────────────
// Angle convention (from the parser): screen coordinates with y pointing DOWN,
// measured from the ring centre. 0° = right, 90° = down, 180° = left, 270° = up.

var ZONE_ANGLES = {
  right: 0,
  down: 90,
  bottom: 90,   // alias
  left: 180,
  up: 270,
  top: 270,  // alias
};

function normalizeDeg(deg) {
  return ((deg % 360) + 360) % 360;
}

// Smallest absolute difference between two angles, in [0, 180].
function angularDistance(a, b) {
  var d = Math.abs(normalizeDeg(a) - normalizeDeg(b));
  return d > 180 ? 360 - d : d;
}

// Legacy quadrant helper (kept for API compatibility / diagnostics).
function angleToZone(deg) {
  deg = normalizeDeg(deg);
  if (deg >= 315 || deg < 45) return 'right';
  if (deg >= 45 && deg < 135) return 'bottom';
  if (deg >= 135 && deg < 225) return 'left';
  return 'top'; // 225-315
}

// Does an instance angle satisfy a directionZone and/or directionAngle spec,
// within the given angular error? Returns true when no direction constraint set.
function directionMatches(angleDeg, signReq, toleranceDeg) {
  var tol = signReq.directionToleranceDeg !== undefined
    ? signReq.directionToleranceDeg : toleranceDeg;

  if (signReq.directionZone) {
    var target = ZONE_ANGLES[String(signReq.directionZone).toLowerCase()];
    if (target === undefined) return false; // unknown zone name
    if (angularDistance(angleDeg, target) > tol) return false;
  }

  if (signReq.directionAngle !== undefined) {
    var targets = Array.isArray(signReq.directionAngle)
      ? signReq.directionAngle : [signReq.directionAngle];
    var ok = false;
    for (var i = 0; i < targets.length; i++) {
      if (angularDistance(angleDeg, targets[i]) <= tol) { ok = true; break; }
    }
    if (!ok) return false;
  }

  return true;
}

// Are the given instance angles evenly spaced around the ring (rotation-free)?
// n instances are equiangular when every consecutive gap ≈ 360/n within tol.
function isEquiangular(angles, toleranceDeg) {
  var n = angles.length;
  if (n <= 1) return true;
  var sorted = angles.slice().map(normalizeDeg).sort(function(a, b) { return a - b; });
  var expected = 360 / n;
  for (var i = 0; i < n; i++) {
    var next = (i + 1 < n) ? sorted[i + 1] : sorted[0] + 360;
    var gap = next - sorted[i];
    if (Math.abs(gap - expected) > toleranceDeg) return false;
  }
  return true;
}

// ─── SIGIL MATCHING ─────────────────────────────────────────────────────────
// Spells reference sigils loosely (e.g. "fire"). Match case-insensitively against
// EITHER the recognised sigil's id ("Fire") OR its element ("fire"), and accept an
// explicit { element: "fire" } spec too. This decouples the human-friendly
// dictionary from the exact template ids in sigils.json.
function sigilRefMatches(reqSigil, primarySigil) {
  if (reqSigil.element) {
    if (!primarySigil.element) return false;
    return String(primarySigil.element).toLowerCase() === String(reqSigil.element).toLowerCase();
  }
  if (reqSigil.id) {
    var want = String(reqSigil.id).toLowerCase();
    var haveId = primarySigil.id ? String(primarySigil.id).toLowerCase() : null;
    var haveEl = primarySigil.element ? String(primarySigil.element).toLowerCase() : null;
    return want === haveId || want === haveEl;
  }
  return true; // no id/element constraint → any sigil satisfies
}

// ─── SPELL MATCHER ──────────────────────────────────────────────────────────

function matchSpell(glyphAST, dictionary) {
  if (!glyphAST || !dictionary || !dictionary.spells) return null;
  if (!glyphAST.ring || !glyphAST.ring.complete) return null;

  var results = [];

  for (var i = 0; i < dictionary.spells.length; i++) {
    var entry = dictionary.spells[i];
    var result = scoreEntry(entry, glyphAST, dictionary);
    if (result.matched) {
      results.push({
        entry: entry, score: result.score, diagnostics: result.diagnostics,
        specificity: entrySpecificity(entry),
      });
    }
  }

  if (results.length === 0) return null;
  // Rank by glyph-quality score, breaking ties toward the MORE SPECIFIC spell so a
  // constrained binding (e.g. light + a directional column) beats a generic one
  // (light + no signs) that also happens to match.
  results.sort(function(a, b) {
    if (b.score !== a.score) return b.score - a.score;
    return b.specificity - a.specificity;
  });
  return results[0];
}

// How many constraints a spell imposes — used only as a tie-breaker.
function entrySpecificity(entry) {
  var match = entry.match || {};
  var spec = 0;
  if (match.primarySigil && (match.primarySigil.id || match.primarySigil.element)) spec += 1;
  if (match.ring && match.ring.minCompleteness) spec += 1;
  if (match.signs) {
    for (var i = 0; i < match.signs.length; i++) {
      var r = match.signs[i];
      spec += 1;
      if (r.directionZone) spec += 1;
      if (r.directionAngle !== undefined) spec += 1;
      if ((r.count !== undefined ? r.count : 1) >= 2) spec += 1;
      if (r.minElongation) spec += 1;
    }
  }
  return spec;
}

function scoreEntry(entry, glyphAST, dictionary) {
  var tol = mergeTolerances(dictionary, entry);
  var match = entry.match || {};
  var diagnostics = {};

  // 1. Primary sigil check (by id OR element, case-insensitive).
  if (match.primarySigil) {
    if (!glyphAST.primarySigil) return { matched: false, reason: 'no_primary_sigil' };
    if (!sigilRefMatches(match.primarySigil, glyphAST.primarySigil))
      return { matched: false, reason: 'sigil_mismatch' };
    if (glyphAST.primarySigil.confidence < tol.sigilMinConfidence)
      return { matched: false, reason: 'sigil_confidence_too_low' };
    diagnostics.sigil = {
      id: glyphAST.primarySigil.id,
      element: glyphAST.primarySigil.element,
      confidence: glyphAST.primarySigil.confidence,
    };
  }

  // 2. Ring completeness check.
  if (match.ring) {
    if (match.ring.minCompleteness && glyphAST.ring.completeness < match.ring.minCompleteness)
      return { matched: false, reason: 'ring_incomplete' };
  }

  // 3. Signs check.
  if (match.signs) {
    for (var i = 0; i < match.signs.length; i++) {
      var signReq = match.signs[i];
      var dirTol = signReq.directionToleranceDeg !== undefined
        ? signReq.directionToleranceDeg : tol.directionToleranceDeg;

      var matchingInstances = glyphAST.signs.filter(function(s) {
        if (s.id !== signReq.id) return false;
        if (s.confidence < tol.signMinConfidence) return false;
        if (signReq.minElongation && s.elongation < signReq.minElongation) return false;
        if (!directionMatches(s.angleDeg, signReq, dirTol)) return false;
        return true;
      });

      var count = matchingInstances.length;
      var reqCount = signReq.count !== undefined ? signReq.count : 1;
      var mode = signReq.countMode || 'exact';

      var countOk = mode === 'exact' ? count === reqCount
        : mode === 'min' ? count >= reqCount
          : mode === 'max' ? count <= reqCount : false;

      if (!countOk)
        return { matched: false, reason: 'sign_count_mismatch:' + signReq.id + ' (got ' + count + ', need ' + reqCount + ')' };

      // Equiangular placement: by default, a requirement for n≥2 signs (exact
      // count) expects them evenly spaced around the ring. Opt out with
      // "equiangular": false, or force it on for min/max modes with true.
      var wantEquiangular = signReq.equiangular;
      if (wantEquiangular === undefined)
        wantEquiangular = (mode === 'exact' && reqCount >= 2);

      var eqTol = signReq.equiangularToleranceDeg !== undefined
        ? signReq.equiangularToleranceDeg : tol.equiangularToleranceDeg;
      var angles = matchingInstances.map(function(s) { return s.angleDeg; });

      if (wantEquiangular && !isEquiangular(angles, eqTol))
        return { matched: false, reason: 'signs_not_equiangular:' + signReq.id };

      diagnostics['sign_' + signReq.id] = {
        count: count,
        equiangular: wantEquiangular ? isEquiangular(angles, eqTol) : null,
        confidences: matchingInstances.map(function(s) { return s.confidence; }),
        angles: angles,
      };
    }
  }

  // 4. Global stability gate.
  if (glyphAST.globalMetrics.instability > tol.maxInstability)
    return { matched: false, reason: 'too_unstable (' + glyphAST.globalMetrics.instability.toFixed(2) + ')' };

  // 5. Compute match score.
  var score = 0;
  if (glyphAST.primarySigil) score += glyphAST.primarySigil.confidence * 0.40;
  score += glyphAST.globalMetrics.neatness * 0.30;
  score += glyphAST.globalMetrics.radialSymmetry * 0.30;

  return { matched: true, score: score, diagnostics: diagnostics };
}

// ─── HOOK REGISTRY ──────────────────────────────────────────────────────────

var _hooks = {};

function registerHook(hookId, fn) {
  _hooks[hookId] = fn;
}

function dispatchHook(matchResult, glyphAST) {
  if (!matchResult) return false;
  var entry = matchResult.entry;
  var fn = _hooks[entry.hookId];
  if (!fn) {
    console.warn('[SpellDispatcher] No hook for hookId: ' + entry.hookId);
    return false;
  }

  var payload = {
    spellId: entry.id,
    spellName: entry.displayName,
    hookId: entry.hookId,
    glyphAST: glyphAST,
    metrics: glyphAST.globalMetrics,
    sigil: glyphAST.primarySigil,
    signs: glyphAST.signs,
    ring: glyphAST.ring,
    matchScore: matchResult.score,
    matchDiagnostics: matchResult.diagnostics,
    warnings: glyphAST.warnings,
  };

  try {
    fn(payload);
    return true;
  } catch (e) {
    console.error('[SpellDispatcher] Hook threw:', e);
    return false;
  }
}
