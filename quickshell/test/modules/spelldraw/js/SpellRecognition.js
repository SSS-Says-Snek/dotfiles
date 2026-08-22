// SpellRecognition.js — WHA spell parser: candidate grouping, ink template
// matching and symbol (sigil/sign) recognition. Entry points: classifyStrokes,
// groupIntoCandidates, recognizeCandidate, computeGlobalMetrics.
.pragma library
.import "SpellCore.js" as Core

var CONFIG = Core.CONFIG;
var _stash = Core._stash;
var pathLength = Core.pathLength;
var boundingBox = Core.boundingBox;
var normalizeStrokesForTemplate = Core.normalizeStrokesForTemplate;

// ─── STROKE CLASSIFIER ─────────────────────────────────────────────────────

function classifyStrokes(cleanedStrokes, ring) {
  if (!ring.found)
    return { ringStrokes: [], interiorStrokes: cleanedStrokes };

  var idxSet = {};
  for (var i = 0; i < ring.strokeIndices.length; i++) idxSet[ring.strokeIndices[i]] = true;

  var ringStrokes = [], interior = [];
  for (var i = 0; i < cleanedStrokes.length; i++) {
    if (idxSet[i]) ringStrokes.push(cleanedStrokes[i]);
    else interior.push(cleanedStrokes[i]);
  }
  return { ringStrokes: ringStrokes, interiorStrokes: interior };
}

// ─── CANDIDATE GROUPING ────────────────────────────────────────────────────

function strokeBoundsClose(s1, s2, threshold) {
  var b1 = s1.bounds, b2 = s2.bounds;
  return !(b1.maxX + threshold < b2.minX || b2.maxX + threshold < b1.minX ||
    b1.maxY + threshold < b2.minY || b2.maxY + threshold < b1.minY);
}

function measureClosedness(pts) {
  if (pts.length < 2) return 0;
  var dist = Math.hypot(pts[0].x - pts[pts.length - 1].x, pts[0].y - pts[pts.length - 1].y);
  var len = pathLength(pts);
  return len === 0 ? 0 : Math.max(0, 1 - dist / (len * 0.5));
}

function computePrincipalOrientation(pts, c) {
  var mxx = 0, mxy = 0, myy = 0;
  for (var i = 0; i < pts.length; i++) {
    var dx = pts[i].x - c.x, dy = pts[i].y - c.y;
    mxx += dx * dx; mxy += dx * dy; myy += dy * dy;
  }
  return 0.5 * Math.atan2(2 * mxy, mxx - myy);
}

function computeElongation(pts, angle, c) {
  var cos = Math.cos(angle), sin = Math.sin(angle);
  var maxMaj = 0, maxMin = 0;
  for (var i = 0; i < pts.length; i++) {
    var dx = pts[i].x - c.x, dy = pts[i].y - c.y;
    var maj = Math.abs(cos * dx + sin * dy);
    var min = Math.abs(-sin * dx + cos * dy);
    if (maj > maxMaj) maxMaj = maj;
    if (min > maxMin) maxMin = min;
  }
  return maxMin < 0.5 ? 10 : maxMaj / maxMin;
}

// Candidate geometry (points, bounds, orientation, elongation, closedness) depends
// only on the group's strokes, so cache it by stroke-set. Untouched candidates are
// reused wholesale across parses — only the cheap ring-relative fields are refreshed.
var _candGeomCache = {};

var _candGeomCacheCount = 0;

function _groupKey(group) {
  var ids = [];
  for (var i = 0; i < group.length; i++) {
    var sid = group[i]._sid;
    if (sid === undefined) return null;
    ids.push(sid);
  }
  ids.sort(function(a, b) { return a - b; });
  return ids.join(',');
}

function groupIntoCandidates(interiorStrokes, ring) {
  if (interiorStrokes.length === 0) return [];
  // Merge distance scales with ring size: on a small ring a fixed 50px reaches most
  // of the interior and fuses a nearby sign into the sigil. Use max(minPx, frac·r),
  // capped at the absolute default, so grouping behaves consistently at any scale.
  var prox = (ring && ring.found)
    ? Math.max(CONFIG.candidateProximityMinPx,
      Math.min(CONFIG.candidateProximity, ring.radius * CONFIG.candidateProximityFrac))
    : CONFIG.candidateProximity;
  var used = new Uint8Array(interiorStrokes.length);
  var candidates = [];

  for (var i = 0; i < interiorStrokes.length; i++) {
    if (used[i]) continue;
    var group = [interiorStrokes[i]]; used[i] = 1;
    var queue = [i];

    while (queue.length) {
      var curr = queue.shift();
      for (var j = 0; j < interiorStrokes.length; j++) {
        if (used[j]) continue;
        if (strokeBoundsClose(interiorStrokes[curr], interiorStrokes[j], prox)) {
          used[j] = 1; group.push(interiorStrokes[j]); queue.push(j);
        }
      }
    }

    var totalLen = 0;
    for (var k = 0; k < group.length; k++) totalLen += group[k].length;
    if (totalLen < CONFIG.minCandidateLength) continue;

    var key = _groupKey(group);
    var cand = (key !== null) ? _candGeomCache[key] : null;

    if (!cand) {
      var allPts = [];
      for (var k2 = 0; k2 < group.length; k2++)
        for (var m = 0; m < group[k2].points.length; m++) allPts.push(group[k2].points[m]);

      var bb = boundingBox(allPts);
      var cen = { x: (bb.minX + bb.maxX) / 2, y: (bb.minY + bb.maxY) / 2 };
      var orientAngle = computePrincipalOrientation(allPts, cen);

      cand = {
        strokes: group,
        allPoints: allPts,
        bounds: bb,
        center: cen,
        strokeCount: group.length,
        totalLength: totalLen,
        orientationDeg: orientAngle * 180 / Math.PI,
        elongation: computeElongation(allPts, orientAngle, cen),
        closedness: measureClosedness(allPts),
        // ring-relative fields, refreshed below every parse
        radiusNorm: 0, angleDeg: 0, layer: 'center', sizeNorm: 0, lengthNorm: 0,
      };

      if (key !== null) {
        if (_candGeomCacheCount > 4000) { _candGeomCache = {}; _candGeomCacheCount = 0; }
        _candGeomCache[key] = cand;
        _candGeomCacheCount++;
      }
    }

    // Ring-relative fields are cheap and ring-dependent → always refresh.
    if (ring.found) {
      var rdx = cand.center.x - ring.center.x, rdy = cand.center.y - ring.center.y;
      cand.radiusNorm = Math.hypot(rdx, rdy) / ring.radius;
      cand.angleDeg = ((Math.atan2(rdy, rdx) * 180 / Math.PI) + 360) % 360;
      cand.layer = cand.radiusNorm < CONFIG.layerCenter ? 'center'
        : cand.radiusNorm < CONFIG.layerMiddle ? 'middle' : 'outer';
      cand.sizeNorm = Math.max(cand.bounds.maxX - cand.bounds.minX, cand.bounds.maxY - cand.bounds.minY) / (ring.radius * 2);
      cand.lengthNorm = cand.totalLength / (2 * Math.PI * ring.radius);
    } else {
      cand.radiusNorm = 0; cand.angleDeg = 0; cand.layer = 'center'; cand.sizeNorm = 0; cand.lengthNorm = 0;
    }

    candidates.push(cand);
  }

  return candidates;
}

// ─── INK TEMPLATE MATCHING ( port of ytnrvdf templateMatcher.js) ────────────
// Replaces the old single-thickness Jaccard matcher, which scored ~30% low
// because (a) Jaccard/IoU is harsh on thin hand-drawn lines, and (b) it flattened
// every multi-stroke glyph into ONE point list and connected across strokes,
// stamping phantom segments that don't exist in the drawing or template.
//
// This renders each stroke SEPARATELY into three dilation layers (core/soft/loose)
// and blends asymmetric coverage ratios with a soft-Dice term — the same recipe
// the reference simulator uses to reach 80%+ on clean glyphs.

var INK = {
  size: 40,
  core: 1,
  soft: 2,
  loose: 4,
  samples: 40,
};

function _inkLayer(size) { return { mask: new Uint8Array(size * size), ink: 0 }; }

function _markMask(mask, size, x, y, radius) {
  var cx = Math.round(Math.max(0, Math.min(1, x)) * (size - 1));
  var cy = Math.round(Math.max(0, Math.min(1, y)) * (size - 1));
  var r2 = radius * radius;
  for (var oy = -radius; oy <= radius; oy++) {
    for (var ox = -radius; ox <= radius; ox++) {
      if (ox * ox + oy * oy > r2) continue;
      var px = cx + ox, py = cy + oy;
      if (px < 0 || px >= size || py < 0 || py >= size) continue;
      mask[py * size + px] = 1;
    }
  }
}

function _markInk(ink, size, x, y) {
  _markMask(ink.core.mask, size, x, y, INK.core);
  _markMask(ink.soft.mask, size, x, y, INK.soft);
  _markMask(ink.loose.mask, size, x, y, INK.loose);
}

function _rotateUnit(p, transform) {
  if (!transform) return p;
  var x = p.x - 0.5, y = p.y - 0.5;
  return { x: x * transform.cos - y * transform.sin + 0.5, y: x * transform.sin + y * transform.cos + 0.5 };
}

// strokes: array of arrays of {x,y} in ~[0,1]. Rendered per-stroke (no phantom
// segments between strokes), with rotation about the unit-square center.
function renderInk(strokes, rotationDeg) {
  var size = INK.size;
  var ink = { core: _inkLayer(size), soft: _inkLayer(size), loose: _inkLayer(size) };
  var transform = rotationDeg
    ? { cos: Math.cos(rotationDeg * Math.PI / 180), sin: Math.sin(rotationDeg * Math.PI / 180) }
    : null;

  for (var s = 0; s < strokes.length; s++) {
    var stroke = strokes[s];
    if (!stroke || !stroke.length) continue;
    var pts = [];
    for (var i = 0; i < stroke.length; i++) pts.push(_rotateUnit(stroke[i], transform));
    if (pts.length === 1) { _markInk(ink, size, pts[0].x, pts[0].y); continue; }
    for (var k = 1; k < pts.length; k++) {
      var dx = pts[k].x - pts[k - 1].x, dy = pts[k].y - pts[k - 1].y;
      var steps = Math.max(1, Math.ceil(Math.hypot(dx, dy) * size * 2));
      for (var t = 0; t <= steps; t++) {
        var a = t / steps;
        _markInk(ink, size, pts[k - 1].x + dx * a, pts[k - 1].y + dy * a);
      }
    }
  }

  ink.core.ink = _countInk(ink.core.mask);
  ink.soft.ink = _countInk(ink.soft.mask);
  ink.loose.ink = _countInk(ink.loose.mask);
  return ink;
}

function _countInk(mask) { var n = 0; for (var i = 0; i < mask.length; i++) n += mask[i]; return n; }

function _maskOverlap(a, b) {
  var n = 0;
  for (var i = 0; i < a.length; i++) if (a[i] && b[i]) n++;
  return n;
}

function _diceScore(a, b, aInk, bInk) {
  if (!aInk || !bInk) return 0;
  return Math.min(1, (_maskOverlap(a, b) * 2) / (aInk + bInk));
}

// Asymmetric coverage (core vs fattened "loose" band) + soft-Dice → ink score.
function compareInk(candInk, refInk) {
  var cN = candInk.core.ink, rN = refInk.core.ink;
  if (!cN || !rN) return { inkScore: 0, candidateExplainedRatio: 0, templateCoveredRatio: 0, softDiceScore: 0 };

  var explained = Math.min(1, _maskOverlap(candInk.core.mask, refInk.loose.mask) / cN);
  var covered = Math.min(1, _maskOverlap(refInk.core.mask, candInk.loose.mask) / rN);
  var softDice = _diceScore(candInk.soft.mask, refInk.soft.mask, candInk.soft.ink, refInk.soft.ink);

  // Weight template coverage heavily so a small sign that only matches part of a
  // large sigil (column T inside earth) cannot outscore the full sign template.
  var inkScore = Math.min(1,
    explained * 0.26 +
    covered * 0.46 +
    softDice * 0.28);

  return { inkScore: inkScore, candidateExplainedRatio: explained, templateCoveredRatio: covered, softDiceScore: softDice };
}

// Turn raw ink metrics into a final match score with subset/overdraw penalties.
function finalizeMatchScore(metrics, entry, candidate, kind) {
  var score = metrics.inkScore;
  var covered = metrics.templateCoveredRatio;
  var explained = metrics.candidateExplainedRatio;
  var tmplStrokes = entry.strokeTemplate.strokes.length;
  var candStrokes = candidate.strokeCount;
  var strokeDiff = Math.abs(candStrokes - tmplStrokes);

  if (kind === 'sign') {
    // Signs are stroke-count specific (column=2, convergence=3, levitation=4). A T or
    // caret can partially explain a triangle template without being that sign.
    if (tmplStrokes > candStrokes && covered < 0.70)
      score = Math.min(score, covered * 0.90 + explained * 0.05);
    if (candStrokes > tmplStrokes && explained - covered > 0.12)
      score = Math.min(score, score * 0.90);
  } else {
    // Sigil: only penalize when the template is much richer (column T inside earth).
    if (tmplStrokes > candStrokes + 1 && covered < 0.65)
      score = Math.min(score, covered * 0.92 + explained * 0.06);
    if (tmplStrokes > candStrokes + 1 && covered < 0.48)
      score = Math.min(score, 0.44);
  }

  var strokeP = kind === 'sigil'
    ? Math.min(0.20, strokeDiff * 0.035)
    : Math.min(0.28, strokeDiff * 0.09);
  return Math.max(0, score - strokeP);
}

// Bbox normalization — same recipe as normalizeStrokesForTemplate / dictionary JSON.
// Used for SIGIL matching so candidates land in the same canonical frame as templates.
function _normStrokeListBbox(strokeList) {
  var t = normalizeStrokesForTemplate(strokeList, { samplesPerStroke: INK.samples, digits: 5 });
  return t.strokes;
}

// ROTATION-INVARIANT normalization for SIGN matching. Rotates the raw points about
// their centroid by angleDeg, THEN bbox-normalizes with the SAME recipe as the
// stored templates (normalizeStrokesForTemplate). This keeps signs in the identical
// 0–1 bbox frame the templates live in — the key to high self-match scores — while
// the rotation sweep realigns orientation. Re-bboxing per angle (instead of rotating
// inside the unit square) avoids corner clipping at 45°/135° angles.
function _normStrokeListBboxRotated(strokeList, angleDeg) {
  var rad = angleDeg * Math.PI / 180;
  var cos = Math.cos(rad), sin = Math.sin(rad);

  var all = [];
  for (var s = 0; s < strokeList.length; s++)
    if (strokeList[s]) for (var k = 0; k < strokeList[s].length; k++) all.push(strokeList[s][k]);
  if (all.length === 0) return [];

  var cx = 0, cy = 0;
  for (var i = 0; i < all.length; i++) { cx += all[i].x; cy += all[i].y; }
  cx /= all.length; cy /= all.length;

  var rotated = [];
  for (var t = 0; t < strokeList.length; t++) {
    if (!strokeList[t] || strokeList[t].length === 0) continue;
    var stroke = [];
    for (var m = 0; m < strokeList[t].length; m++) {
      var dx = strokeList[t][m].x - cx, dy = strokeList[t][m].y - cy;
      stroke.push({ x: cx + dx * cos - dy * sin, y: cy + dx * sin + dy * cos });
    }
    rotated.push(stroke);
  }
  return _normStrokeListBbox(rotated);
}

function _templateInk(entry) {
  // Dictionary strokes are already normalized to a 0–1 bbox by the template editor.
  // Re-normalizing (especially with centroid scaling) shifts thin multi-stroke sigils
  // like Fire and tanks match scores — render the stored template as-is.
  if (!entry._inkCache)
    _stash(entry, '_inkCache', renderInk(entry.strokeTemplate.strokes, 0));
  return entry._inkCache;
}

function _candidateStrokeList(candidate) {
  var list = [];
  for (var i = 0; i < candidate.strokes.length; i++) list.push(candidate.strokes[i].points);
  return list;
}

function _candidateNormBbox(candidate) {
  if (!candidate._normStrokesBbox)
    _stash(candidate, '_normStrokesBbox', _normStrokeListBbox(_candidateStrokeList(candidate)));
  return candidate._normStrokesBbox;
}

// Candidate ink at a given rotation, keyed by norm mode.
//   'bbox' (sigil): bbox-normalize once, rotate inside the unit square.
//   'sign'         : rotate raw points THEN re-bbox per angle (same frame as
//                    templates), so a perfectly drawn sign self-matches near 1.0.
function _candidateInk(candidate, angleDeg, normMode) {
  var cacheKey = normMode === 'sign' ? '_inkByAngleSign' : '_inkByAngleBbox';
  if (!candidate[cacheKey]) _stash(candidate, cacheKey, {});
  var bucket = Math.round(angleDeg * 4) / 4;
  var cached = candidate[cacheKey][bucket];
  if (cached) return cached;
  var ink;
  if (normMode === 'sign') {
    ink = renderInk(_normStrokeListBboxRotated(_candidateStrokeList(candidate), angleDeg), 0);
  } else {
    ink = renderInk(_candidateNormBbox(candidate), angleDeg);
  }
  candidate[cacheKey][bucket] = ink;
  return ink;
}

function _clearCandidateInkCaches(candidate) {
  if (candidate._inkByAngleBbox) candidate._inkByAngleBbox = {};
  if (candidate._inkByAngleSign) candidate._inkByAngleSign = {};
}

// Best ink metrics over a set of rotations (deg).
function scoreInkTemplate(candidate, entry, rotationsDeg, normMode) {
  var refInk = _templateInk(entry);
  var best = { inkScore: 0, candidateExplainedRatio: 0, templateCoveredRatio: 0, softDiceScore: 0 };
  for (var i = 0; i < rotationsDeg.length; i++) {
    var m = compareInk(_candidateInk(candidate, rotationsDeg[i], normMode), refInk);
    if (m.inkScore > best.inkScore) best = m;
  }
  return best;
}

// Upright sigils: bbox-normalized match. Always include 0° plus a small sweep around
// the candidate's principal axis (hand-drawn fire is often a few degrees off).
function matchDirect(candidate, entry) {
  var angleSet = { 0: true };
  var orient = candidate.orientationDeg || 0;
  var offsets = [-25, -15, -10, -5, 5, 10, 15, 25];
  for (var i = 0; i < offsets.length; i++) angleSet[orient + offsets[i]] = true;
  var rots = [];
  for (var k in angleSet) if (angleSet.hasOwnProperty(k)) rots.push(parseFloat(k));
  return finalizeMatchScore(scoreInkTemplate(candidate, entry, rots, 'bbox'), entry, candidate, 'sigil');
}

function _sigilRotationAngles(candidate, rotationInvariant) {
  if (rotationInvariant)
    return [0, 45, 90, 135, 180, 225, 270, 315];
  var angleSet = { 0: true };
  var orient = candidate.orientationDeg || 0;
  var offsets = [-25, -15, -10, -5, 5, 10, 15, 25];
  for (var i = 0; i < offsets.length; i++) angleSet[orient + offsets[i]] = true;
  var rots = [];
  for (var k in angleSet) if (angleSet.hasOwnProperty(k)) rots.push(parseFloat(k));
  return rots;
}

function matchRotationInvariant(candidate, entry) {
  return finalizeMatchScore(
    scoreInkTemplate(candidate, entry, [0, 45, 90, 135, 180, 225, 270, 315], 'bbox'),
    entry, candidate, 'sigil');
}

// Sign IDENTITY is rotation-tolerant (its orientation encodes direction, computed
// separately). Instead of a fixed dense sweep (signRotationSteps renders), do a
// coarse-to-fine search: a few coarse angles to locate the peak, then refine
// around it. This roughly halves renderInk calls with the same accuracy.
function matchSign(candidate, entry, ring) {
  var refInk = _templateInk(entry);

  // Coarse angles are multiples of 45°, cached per candidate; refine around the peak.
  var coarseN = 8, coarseStep = 360 / coarseN;
  var best = { inkScore: -1, candidateExplainedRatio: 0, templateCoveredRatio: 0, softDiceScore: 0 };
  var bestAng = 0;
  for (var i = 0; i < coarseN; i++) {
    var a = i * coarseStep;
    var m = compareInk(_candidateInk(candidate, a, 'sign'), refInk);
    if (m.inkScore > best.inkScore) { best = m; bestAng = a; }
  }
  var fine = coarseStep / 3;
  for (var d = -2; d <= 2; d++) {
    if (d === 0) continue;
    var fa = bestAng + d * fine;
    var m = compareInk(_candidateInk(candidate, fa, 'sign'), refInk);
    if (m.inkScore > best.inkScore) best = m;
  }

  return finalizeMatchScore(best, entry, candidate, 'sign');
}

function computeSignDirection(candidate, ring, mode) {
  if (mode === 'position')
    return { x: Math.cos(candidate.angleDeg * Math.PI / 180), y: Math.sin(candidate.angleDeg * Math.PI / 180) };
  if (mode === 'inward' && ring.found) {
    var len = Math.hypot(ring.center.x - candidate.center.x, ring.center.y - candidate.center.y) || 1;
    return { x: (ring.center.x - candidate.center.x) / len, y: (ring.center.y - candidate.center.y) / len };
  }
  var pts = candidate.allPoints;
  var da = Math.atan2(pts[pts.length - 1].y - pts[0].y, pts[pts.length - 1].x - pts[0].x);
  return { x: Math.cos(da), y: Math.sin(da) };
}

// ─── SYMBOL RECOGNITION ────────────────────────────────────────────────────

// Template scores depend ONLY on the candidate's own strokes (the ink matcher
// never uses the ring), so they can be cached by the candidate's stroke-set.
// This is the key scaling fix: re-parsing after a new stroke no longer re-scores
// every previously-drawn symbol, only changed/new candidates.
var _recogScoreCache = {};

var _recogScoreCacheCount = 0;

var _cachedSigilDict = null;

var _cachedSignDict = null;

function _candidateStrokeKey(candidate) {
  var ids = [];
  for (var i = 0; i < candidate.strokes.length; i++) {
    var sid = candidate.strokes[i]._sid;
    if (sid === undefined) return null;
    ids.push(sid);
  }
  ids.sort(function(a, b) { return a - b; });
  return ids.join(',');
}

function scoreCandidateTemplates(candidate, sigilDict, signDict) {
  // Cached scores are only valid for the dictionaries they were computed against.
  // SpellDrawer loads dictionaries asynchronously (early parses see empty dicts),
  // so invalidate the whole cache whenever the dictionary identity changes.
  if (sigilDict !== _cachedSigilDict || signDict !== _cachedSignDict) {
    _recogScoreCache = {};
    _recogScoreCacheCount = 0;
    _cachedSigilDict = sigilDict;
    _cachedSignDict = signDict;
  }

  var key = _candidateStrokeKey(candidate);
  if (key !== null && _recogScoreCache[key]) return _recogScoreCache[key];

  var results = [];
  for (var i = 0; i < sigilDict.length; i++) {
    var entry = sigilDict[i];
    var metrics = scoreInkTemplate(candidate, entry,
      _sigilRotationAngles(candidate, entry.recognitionRotationInvariant), 'bbox');
    results.push({
      id: entry.id, kind: 'sigil', score: finalizeMatchScore(metrics, entry, candidate, 'sigil'),
      entry: entry, templateCovered: metrics.templateCoveredRatio,
    });
  }
  for (var j = 0; j < signDict.length; j++) {
    var sEntry = signDict[j];
    results.push({
      id: sEntry.id, kind: 'sign', score: matchSign(candidate, sEntry, null), entry: sEntry,
    });
  }

  _clearCandidateInkCaches(candidate);

  if (key !== null) {
    if (_recogScoreCacheCount > 4000) { _recogScoreCache = {}; _recogScoreCacheCount = 0; }
    _recogScoreCache[key] = results;
    _recogScoreCacheCount++;
  }
  return results;
}

function recognizeCandidate(candidate, sigilDict, signDict, ring) {
  // Layer gating only applies when a ring is present to define layers. Without a
  // ring every candidate is nominally 'center', so gating there would silently
  // drop all middle/outer signs (and block standalone testing). Allow all then.
  var gateLayers = ring.found;

  var scored = scoreCandidateTemplates(candidate, sigilDict, signDict);
  var results = [];
  for (var k = 0; k < scored.length; k++) {
    if (gateLayers && scored[k].entry.allowedLayers.indexOf(candidate.layer) === -1) continue;
    results.push(scored[k]);
  }

  // Pick the best sigil and best sign separately — do not let a partial sigil match
  // (column T inside earth) beat the correct sign because it sorts higher globally.
  var bestSigil = null, bestSign = null, bestSignRank = -1;
  for (var ri = 0; ri < results.length; ri++) {
    var row = results[ri];
    if (row.kind === 'sigil' && (!bestSigil || row.score > bestSigil.score)) bestSigil = row;
    if (row.kind === 'sign') {
      var rank = row.score;
      if (row.entry.strokeTemplate.strokes.length === candidate.strokeCount) rank += 0.03;
      if (!bestSign || rank > bestSignRank) { bestSign = row; bestSignRank = rank; }
    }
  }

  var best = null;
  if (bestSign && bestSign.score >= CONFIG.minConfidence) {
    var preferSign = !bestSigil
      || bestSign.score >= bestSigil.score - 0.04
      || (bestSigil.templateCovered !== undefined && bestSigil.templateCovered < 0.58
        && bestSign.score >= bestSigil.score - 0.14);
    if (preferSign) best = bestSign;
  }
  if (!best && bestSigil && bestSigil.score >= CONFIG.minConfidence) best = bestSigil;

  if (!best) {
    var guess = (bestSigil && bestSigil.score >= (bestSign ? bestSign.score : 0)) ? bestSigil : bestSign;
    return { recognized: false, kind: 'unknown', bestGuess: guess || null };
  }

  var secondSameKind = null;
  for (var si = 0; si < results.length; si++) {
    if (results[si].kind !== best.kind || results[si].id === best.id) continue;
    if (!secondSameKind || results[si].score > secondSameKind.score) secondSameKind = results[si];
  }
  var gap = secondSameKind ? (best.score - secondSameKind.score) : 1;
  var ambiguous = secondSameKind && gap < 0.08;
  if (best.kind === 'sign' && secondSameKind) {
    var bestTmplN = best.entry.strokeTemplate.strokes.length;
    var secondTmplN = secondSameKind.entry.strokeTemplate.strokes.length;
    if (bestTmplN === candidate.strokeCount && secondTmplN !== candidate.strokeCount && gap >= 0.04)
      ambiguous = false;
  }
  if (best.score >= 0.88 && gap >= 0.02) ambiguous = false;
  var status = ambiguous ? 'ambiguous' : (best.score >= 0.70 ? 'valid' : 'valid_messy');
  var neatness = candidate.closedness * 0.3
    + Math.max(0, 1 - Math.abs(candidate.elongation - 1) / 5) * 0.7;

  var result = {
    recognized: !ambiguous,
    id: best.id,
    kind: best.kind,
    confidence: best.score,
    status: status,
    entry: best.entry,
    layer: candidate.layer,
    radiusNorm: candidate.radiusNorm,
    angleDeg: candidate.angleDeg,
    sizeNorm: candidate.sizeNorm,
    lengthNorm: candidate.lengthNorm,
    neatness: neatness,
    elongation: candidate.elongation,
  };

  if (best.kind === 'sign' && best.entry.semantic)
    result.direction = computeSignDirection(candidate, ring, best.entry.semantic.directionMode);
  if (best.kind === 'sigil' && best.entry.element)
    result.element = best.entry.element;

  return result;
}

// ─── GLOBAL METRICS ────────────────────────────────────────────────────────

function computeGlobalMetrics(ring, primarySigil, signs) {
  var components = [ring.neatness || 0];
  if (primarySigil) components.push(primarySigil.neatness || 0);
  for (var i = 0; i < signs.length; i++) components.push(signs[i].neatness || 0);
  var neatness = 0;
  for (var i = 0; i < components.length; i++) neatness += components[i];
  neatness /= components.length;

  var radialSymmetry = 1;
  if (signs.length > 0) {
    var sx = 0, sy = 0;
    for (var j = 0; j < signs.length; j++) {
      sx += Math.cos(signs[j].angleDeg * Math.PI / 180);
      sy += Math.sin(signs[j].angleDeg * Math.PI / 180);
    }
    radialSymmetry = 1 - Math.hypot(sx, sy) / signs.length;
  }

  var instability = 0;
  instability += (1 - (ring.neatness || 0)) * 0.25;
  if (primarySigil) {
    instability += (1 - primarySigil.confidence) * 0.30;
    if (primarySigil.status === 'ambiguous') instability += 0.20;
  } else instability += 0.40;
  instability += (1 - radialSymmetry) * 0.15;
  instability += (1 - (ring.coverageRatio || 0)) * 0.10;
  instability = Math.min(1, Math.max(0, instability));

  return { neatness: neatness, radialSymmetry: radialSymmetry, instability: instability };
}
