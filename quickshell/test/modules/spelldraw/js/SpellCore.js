// SpellCore.js — WHA spell parser: shared CONFIG, geometry & stroke primitives.
// Pure helpers with no dependencies. Imported by SpellRing, SpellRecognition,
// SpellParser and SpellTemplateExport. (normalizeStrokesForTemplate lives here
// because both recognition normalization and template authoring need it.)
.pragma library

var CONFIG = {
  smoothingPasses: 3,
  minStrokeLength: 8,

  // Full ring candidate (single stroke)
  ringMinRadius: 30,
  ringMaxRadius: 900,
  ringRelResidualMax: 0.14,
  ringMinAngularSpan: 170,   // single-stroke ring must span >170°
  ringMinLengthRatio: 0.45,

  // Arc candidate (per-stroke, for multi-stroke merging)
  arcMinAngularSpan: 0,    // short closing arcs can be ~40–50°
  arcMinLengthRatio: 0.08,

  // Gather extra strokes onto an identified ring (ytnrvdf collectOpenRingStrokes)
  ringCollectMinNearRatio: 0.38,
  ringNearHalfWidthRatio: 0.07,
  ringNearHalfWidthMinPx: 12,

  // Overlap/connectivity merging: a stroke that physically touches an existing
  // ring stroke is absorbed into the ring (handles closing strokes drawn just
  // off the fitted circle). Distance is max(px, frac * radius).
  ringOverlapMinPx: 18,
  ringOverlapFrac: 0.06,
  ringOverlapMinOnRingPx: 8,   // overlap-merged stroke must still touch the band a little

  // Multi-stroke merging: two arcs are compatible if their fitted circles agree
  arcMergeMaxCenterDistFrac: 0.22,
  arcMergeMaxRadiusDiffFrac: 0.16,

  // Flood fill — only stamp ink sampled within this band (prevents tail bridges)
  floodGridSize: 224,   // grid is O(G²); 224² ≈ half of 320² with same closedness sensitivity
  floodInkThicknessPct: 0.01125,
  floodPenetrationMax: 0.08,
  ringFloodInlierFrac: 0.11,

  // Point lists for angular gap / neatness
  ringInlierClipFrac: 0.20,
  ringGapBuckets: 96,
  ringInlierFrac: 0.20,
  ringClosedCoverage: 0.88,
  ringMinNearCircleInk: 0.45,  // fraction of ring stroke length on the circle

  // Prepared-ring continuity when sealing with another stroke
  closureRelevantBoundaryFrac: 1.08,
  closureRelevantMinInsideRatio: 0.12,
  activationMinCoverage: 0.50,

  candidateProximity: 50,   // absolute px cap for merging strokes into one symbol
  candidateProximityFrac: 0.15, // …but on small rings use max(18, 15% of radius) so a
  candidateProximityMinPx: 18,  //   sign near the sigil isn't swallowed into it
  minCandidateLength: 12,

  layerCenter: 0.24,  // sigil-only zone radius (frac of ring r); lower = signs
  layerMiddle: 0.68,  //   may sit closer to the sigil (helps small/tight rings)

  minConfidence: 0.45,
};

// ─── GEOMETRY ──────────────────────────────────────────────────────────────

function pathLength(pts) {
  var t = 0;
  for (var i = 1; i < pts.length; i++)
    t += Math.hypot(pts[i].x - pts[i - 1].x, pts[i].y - pts[i - 1].y);
  return t;
}

function boundingBox(pts) {
  var minX = Infinity, minY = Infinity, maxX = -Infinity, maxY = -Infinity;
  for (var i = 0; i < pts.length; i++) {
    if (pts[i].x < minX) minX = pts[i].x;
    if (pts[i].y < minY) minY = pts[i].y;
    if (pts[i].x > maxX) maxX = pts[i].x;
    if (pts[i].y > maxY) maxY = pts[i].y;
  }
  return { minX: minX, minY: minY, maxX: maxX, maxY: maxY };
}

function angleDiffRad(a, b) {
  var d = a - b;
  while (d > Math.PI) d -= 2 * Math.PI;
  while (d < -Math.PI) d += 2 * Math.PI;
  return d;
}

// STROKE CLEANING
// weighted 3-point average (endpoints fixed), repeated N times, then
// filter by minimum path length.

function smoothPointsOnce(points) {
  if (points.length < 4) return points.slice();
  var out = [];
  for (var i = 0; i < points.length; i++) {
    if (i === 0 || i === points.length - 1) {
      out.push({ x: points[i].x, y: points[i].y });
    } else {
      out.push({
        x: points[i - 1].x * 0.25 + points[i].x * 0.50 + points[i + 1].x * 0.25,
        y: points[i - 1].y * 0.25 + points[i].y * 0.50 + points[i + 1].y * 0.25,
      });
    }
  }
  return out;
}

function cleanStroke(rawPoints) {
  if (rawPoints.length < 2) return null;
  var pts = rawPoints.slice();
  for (var pass = 0; pass < CONFIG.smoothingPasses; pass++)
    pts = smoothPointsOnce(pts);
  var len = pathLength(pts);
  if (len < CONFIG.minStrokeLength) return null;
  return { points: pts, length: len, bounds: boundingBox(pts) };
}

// ─── RESAMPLING ────────────────────────────────────────────────────────────
// Linear-scan resampler — no array rebuilding, no stuck-duplicate bug.

function resampleUniform(pts, n) {
  if (pts.length < 2) {
    var r = [];
    for (var k = 0; k < n; k++) r.push({ x: pts[0].x, y: pts[0].y });
    return r;
  }
  var total = pathLength(pts);
  if (total < 1e-6) {
    var r = [];
    for (var k = 0; k < n; k++) r.push({ x: pts[0].x, y: pts[0].y });
    return r;
  }
  var interval = total / (n - 1);
  var resampled = [{ x: pts[0].x, y: pts[0].y }];
  var D = 0;

  for (var i = 1; i < pts.length && resampled.length < n; i++) {
    var dx = pts[i].x - pts[i - 1].x;
    var dy = pts[i].y - pts[i - 1].y;
    var segLen = Math.hypot(dx, dy);
    var consumed = 0;

    while (D + (segLen - consumed) >= interval && resampled.length < n) {
      var step = interval - D;
      consumed += step;
      var frac = consumed / segLen;
      resampled.push({
        x: pts[i - 1].x + frac * dx,
        y: pts[i - 1].y + frac * dy,
      });
      D = 0;
    }
    D += (segLen - consumed);
  }

  while (resampled.length < n)
    resampled.push({ x: pts[pts.length - 1].x, y: pts[pts.length - 1].y });
  return resampled;
}

// Cache rendered ink on the entry, but as a NON-ENUMERABLE field so it is never
// serialized into the GlyphAST output (the entry is embedded there verbatim).
function _stash(obj, key, value) {
  Object.defineProperty(obj, key, { value: value, enumerable: false, configurable: true, writable: true });
  return value;
}

// ─── TEMPLATE EXPORT (sigils.json / signs.json authoring) ───────────────────

function normalizeStrokesForTemplate(rawStrokeArrays, options) {
  options = options || {};
  var samplesPerStroke = options.samplesPerStroke || 32;
  var digits = options.digits !== undefined ? options.digits : 4;
  var factor = Math.pow(10, digits);

  var sourceStrokes = [];
  for (var si = 0; si < rawStrokeArrays.length; si++) {
    if (rawStrokeArrays[si] && rawStrokeArrays[si].length > 0)
      sourceStrokes.push(rawStrokeArrays[si]);
  }
  if (sourceStrokes.length === 0)
    return { sourceAspectRatio: 1, strokes: [] };

  var allPts = [];
  for (var i = 0; i < sourceStrokes.length; i++)
    for (var j = 0; j < sourceStrokes[i].length; j++) allPts.push(sourceStrokes[i][j]);

  var bb = boundingBox(allPts);
  var scale = Math.max(bb.maxX - bb.minX, bb.maxY - bb.minY, 0.0001);
  var cx = (bb.minX + bb.maxX) / 2;
  var cy = (bb.minY + bb.maxY) / 2;

  var normalizedStrokes = [];
  for (var s = 0; s < sourceStrokes.length; s++) {
    var sampled = resampleUniform(sourceStrokes[s], samplesPerStroke);
    var strokeOut = [];
    for (var k = 0; k < sampled.length; k++) {
      strokeOut.push({
        x: Math.round(((sampled[k].x - cx) / scale + 0.5) * factor) / factor,
        y: Math.round(((sampled[k].y - cy) / scale + 0.5) * factor) / factor,
      });
    }
    normalizedStrokes.push(strokeOut);
  }

  return {
    sourceAspectRatio: Math.round(((bb.maxX - bb.minX) / Math.max(0.0001, bb.maxY - bb.minY)) * 1000) / 1000,
    strokes: normalizedStrokes,
  };
}
