.pragma library
.import "SpellCore.js" as Core

var CONFIG = Core.CONFIG;
var _stash = Core._stash;
var pathLength = Core.pathLength;
var angleDiffRad = Core.angleDiffRad;

function taubinCircleFit(pts) {
  var n = pts.length;
  if (n < 5) return null;

  var mx = 0, my = 0;
  for (var i = 0; i < n; i++) { mx += pts[i].x; my += pts[i].y; }
  mx /= n; my /= n;

  var Suu=0, Svv=0, Suv=0, Suuu=0, Svvv=0, Suuv=0, Suvv=0;
  for (var i = 0; i < n; i++) {
    var u = pts[i].x - mx, v = pts[i].y - my;
    var u2 = u*u, v2 = v*v;
    Suu  += u2;   Svv  += v2;   Suv  += u*v;
    Suuu += u2*u; Svvv += v2*v;
    Suuv += u2*v; Suvv += u*v2;
  }
  Suu/=n; Svv/=n; Suv/=n; Suuu/=n; Svvv/=n; Suuv/=n; Suvv/=n;

  var A = 2.0 * (Suu*Svv - Suv*Suv);
  if (Math.abs(A) < 1e-10) return null;

  var uc = (Svv * (Suuu + Suvv) - Suv * (Svvv + Suuv)) / A;
  var vc = (Suu * (Svvv + Suuv) - Suv * (Suuu + Suvv)) / A;

  var cx = uc + mx;
  var cy = vc + my;
  var r  = Math.sqrt(uc*uc + vc*vc + Suu + Svv);
  if (r < 1) return null;

  var res = 0;
  for (var i = 0; i < n; i++) {
    var d = Math.hypot(pts[i].x - cx, pts[i].y - cy) - r;
    res += d * d;
  }
  var residual = Math.sqrt(res / n);
  return { cx: cx, cy: cy, r: r, residual: residual, relResidual: residual / r };
}

function angularSpanDeg(pts, cx, cy) {
  if (pts.length < 2) return 0;
  var angles = [];
  for (var i = 0; i < pts.length; i++)
    angles.push(Math.atan2(pts[i].y - cy, pts[i].x - cx) * 180 / Math.PI);
  angles.sort(function(a, b) { return a - b; });
  var maxGap = angles[0] + 360 - angles[angles.length - 1];
  for (var i = 1; i < angles.length; i++)
    maxGap = Math.max(maxGap, angles[i] - angles[i-1]);
  return 360 - maxGap;
}

function ringNearHalfWidth(r) {
  return Math.max(CONFIG.ringNearHalfWidthMinPx, r * CONFIG.ringNearHalfWidthRatio);
}

function strokeNearCircleMetrics(points, cx, cy, r, bins) {
  var half = ringNearHalfWidth(r);
  var sampleStep = 2.0;   // band tolerance is >=12px, so 2px sampling is ample (was 0.75 -> ~3x the work)
  var totalLen = 0, nearLen = 0;

  for (var i = 1; i < points.length; i++) {
    var dx = points[i].x - points[i-1].x;
    var dy = points[i].y - points[i-1].y;
    var segLen = Math.hypot(dx, dy);
    if (segLen <= 0) continue;
    totalLen += segLen;
    var steps = Math.max(1, Math.ceil(segLen / sampleStep));
    var sampleLen = segLen / steps;

    for (var step = 1; step <= steps; step++) {
      var t = step / steps;
      var px = points[i-1].x + dx * t;
      var py = points[i-1].y + dy * t;
      var dist = Math.hypot(px - cx, py - cy);
      if (Math.abs(dist - r) <= half) {
        nearLen += sampleLen;
        if (bins) {
          var a = Math.atan2(py - cy, px - cx);
          var b = Math.floor(((a + Math.PI) / (2 * Math.PI)) * bins.length) % bins.length;
          bins[b] = 1;
        }
      }
    }
  }

  return { totalLength: totalLen, nearLength: nearLen, nearRatio: totalLen > 0 ? nearLen / totalLen : 0 };
}

// Subsample a point list for cheap O(n·m) proximity tests.
function sampleStrokePoints(points, maxN) {
  if (points.length <= maxN) return points;
  var out = [], step = points.length / maxN;
  for (var i = 0; i < maxN; i++) out.push(points[Math.floor(i * step)]);
  return out;
}

// Two strokes "overlap" if any sampled point of one is within `threshold` of any
// sampled point of the other (i.e. the ink physically touches/crosses).
function strokesOverlap(pts1, pts2, threshold) {
  var a = sampleStrokePoints(pts1, 80);
  var b = sampleStrokePoints(pts2, 80);
  var th2 = threshold * threshold;
  for (var i = 0; i < a.length; i++) {
    for (var j = 0; j < b.length; j++) {
      var dx = a[i].x - b[j].x, dy = a[i].y - b[j].y;
      if (dx * dx + dy * dy <= th2) return true;
    }
  }
  return false;
}

function _setKeys(set) {
  var out = [];
  for (var k in set) if (set.hasOwnProperty(k)) out.push(parseInt(k, 10));
  return out;
}

// Refit the circle using only points that already lie in the ring band, so a
// merged stroke's off-circle excursions can't drag the center/radius around.
function inlierRefit(cleanedStrokes, indices, fit) {
  var band = fit.r * CONFIG.ringInlierClipFrac;
  var pts = [];
  for (var i = 0; i < indices.length; i++) {
    var sp = cleanedStrokes[indices[i]].points;
    for (var j = 0; j < sp.length; j++) {
      var d = Math.hypot(sp[j].x - fit.cx, sp[j].y - fit.cy);
      if (Math.abs(d - fit.r) <= band) pts.push(sp[j]);
    }
  }
  if (pts.length < 8) return fit;
  var f = taubinCircleFit(pts);
  return f || fit;
}

// Grow a ring stroke set from a seed by two complementary rules:
//   1. near-circle: the stroke lies on the fitted circle (classic), OR
//   2. overlap/connectivity: the stroke physically touches a stroke already in
//      the ring (handles closing strokes drawn slightly off the fitted band).
// After each pass the circle is re-fit from inlier points only, keeping it stable.
function gatherRingStrokes(cleanedStrokes, seedIndices, cx, cy, r) {
  var set = {};
  for (var i = 0; i < seedIndices.length; i++) set[seedIndices[i]] = true;
  var fit = { cx: cx, cy: cy, r: r };

  var changed = true, guard = 0;
  while (changed && guard++ < 12) {
    changed = false;
    var members = _setKeys(set);
    var overlapTh = Math.max(CONFIG.ringOverlapMinPx, fit.r * CONFIG.ringOverlapFrac);

    for (var si = 0; si < cleanedStrokes.length; si++) {
      if (set[si]) continue;
      var pts = cleanedStrokes[si].points;
      var m = strokeNearCircleMetrics(pts, fit.cx, fit.cy, fit.r, null);

      var nearOk = m.nearRatio >= CONFIG.ringCollectMinNearRatio && m.nearLength >= 12;

      var connected = false;
      if (!nearOk) {
        // Connectivity path: must touch a ring stroke AND still graze the band,
        // so an interior sigil that merely brushes the ring isn't swallowed whole.
        if (m.nearLength >= CONFIG.ringOverlapMinOnRingPx) {
          for (var mi = 0; mi < members.length; mi++) {
            if (strokesOverlap(pts, cleanedStrokes[members[mi]].points, overlapTh)) {
              connected = true;
              break;
            }
          }
        }
      }

      if (nearOk || connected) {
        set[si] = true;
        changed = true;
      }
    }

    fit = inlierRefit(cleanedStrokes, _setKeys(set), fit);
  }

  var out = _setKeys(set);
  out.sort(function(a, b) { return a - b; });
  return { indices: out, fit: fit };
}

function closureRelevantStrokeIndices(cleanedStrokes, prevRing, ringIndices) {
  if (!prevRing || !prevRing.found) return null;

  var prevSet = {};
  if (prevRing.strokeIndices) {
    for (var i = 0; i < prevRing.strokeIndices.length; i++)
      prevSet[prevRing.strokeIndices[i]] = true;
  }

  var ringSet = {};
  for (var j = 0; j < ringIndices.length; j++) ringSet[ringIndices[j]] = true;

  var cx = prevRing.center.x, cy = prevRing.center.y;
  var boundary = prevRing.radius * CONFIG.closureRelevantBoundaryFrac;
  var relevant = [];

  for (var si = 0; si < cleanedStrokes.length; si++) {
    if (ringSet[si] || prevSet[si]) { relevant.push(si); continue; }
    var pts = cleanedStrokes[si].points;
    var inside = 0;
    for (var pi = 0; pi < pts.length; pi++) {
      if (Math.hypot(pts[pi].x - cx, pts[pi].y - cy) <= boundary) inside++;
    }
    if (inside / Math.max(1, pts.length) >= CONFIG.closureRelevantMinInsideRatio)
      relevant.push(si);
  }

  return relevant;
}

function collectPointsFromIndices(cleanedStrokes, indices) {
  var pts = [];
  for (var i = 0; i < indices.length; i++) {
    var stroke = cleanedStrokes[indices[i]];
    if (!stroke) continue;
    for (var pi = 0; pi < stroke.points.length; pi++) pts.push(stroke.points[pi]);
  }
  return pts;
}

function clipPointsToRingBand(pts, cx, cy, r, bandFrac) {
  var band = r * bandFrac;
  var clipped = [];
  for (var i = 0; i < pts.length; i++) {
    var dist = Math.hypot(pts[i].x - cx, pts[i].y - cy);
    if (Math.abs(dist - r) <= band) clipped.push(pts[i]);
  }
  return clipped;
}

function measureRingNearCircleInkRatio(cleanedStrokes, indices, cx, cy, r) {
  var total = 0, near = 0;
  for (var i = 0; i < indices.length; i++) {
    var m = strokeNearCircleMetrics(cleanedStrokes[indices[i]].points, cx, cy, r, null);
    total += m.totalLength;
    near  += m.nearLength;
  }
  return total > 0 ? near / total : 0;
}

function scoreArcCandidate(stroke) {
  // Arc score depends only on the stroke itself, so cache it on the (reused)
  // cleaned-stroke object — detectRing re-scores every stroke on every parse.
  if (stroke._arc !== undefined) return stroke._arc;

  var result = (function () {
    var pts = stroke.points;
    var fit = taubinCircleFit(pts);
    if (!fit) return null;
    if (fit.r < CONFIG.ringMinRadius || fit.r > CONFIG.ringMaxRadius) return null;
    if (fit.relResidual > CONFIG.ringRelResidualMax) return null;

    var span = angularSpanDeg(pts, fit.cx, fit.cy);
    if (span < CONFIG.arcMinAngularSpan) return null;

    var lenRatio = stroke.length / (2 * Math.PI * fit.r);
    if (lenRatio < CONFIG.arcMinLengthRatio) return null;

    return { fit: fit, span: span, lenRatio: lenRatio };
  })();

  _stash(stroke, '_arc', result);
  return result;
}

// ─── MULTI-STROKE RING DETECTION ───────────────────────────────────────────
// 1. Score every stroke as an arc candidate (loose threshold)
// 2. Cluster compatible arcs (centers and radii agree within tolerance)
// 3. For each cluster, run Taubin on all combined points → joint fit
// 4. Pick the cluster whose joint fit scores best as a full ring candidate
//
// A "full ring candidate" from a cluster must:
//   - relResidual < ringRelResidualMax (still circular overall)
//   - angular span > ringMinAngularSpan
//   - length ratio > ringMinLengthRatio

function finalizeRingMeasurement(cleanedStrokes, strokeIndices, jointFit, prevRing) {
  var cx = jointFit.cx, cy = jointFit.cy, r = jointFit.r;

  var gathered = gatherRingStrokes(cleanedStrokes, strokeIndices, cx, cy, r);
  strokeIndices = gathered.indices;
  cx = gathered.fit.cx; cy = gathered.fit.cy; r = gathered.fit.r;

  var refitPts = collectPointsFromIndices(cleanedStrokes, strokeIndices);
  var refit = refitPts.length >= 8 ? inlierRefit(cleanedStrokes, strokeIndices, { cx: cx, cy: cy, r: r }) : null;
  if (refit) { cx = refit.cx; cy = refit.cy; r = refit.r; jointFit = refit; }

  // Ensure relResidual exists even if the refit fell back to a fitless estimate.
  var relResidual = (jointFit && jointFit.relResidual !== undefined)
    ? jointFit.relResidual
    : (function () {
        var fr = refitPts.length >= 5 ? taubinCircleFit(refitPts) : null;
        return fr ? fr.relResidual : 1;
      })();

  var floodIndices = strokeIndices;
  var relevant = closureRelevantStrokeIndices(cleanedStrokes, prevRing, strokeIndices);
  if (relevant && relevant.length >= 1) floodIndices = relevant;

  var floodStrokes = [];
  for (var fi = 0; fi < floodIndices.length; fi++)
    floodStrokes.push(cleanedStrokes[floodIndices[fi]]);

  var angGap = measureAngularGapFromStrokes(floodStrokes, cx, cy, r);
  var clippedPts = clipPointsToRingBand(collectPointsFromIndices(cleanedStrokes, strokeIndices), cx, cy, r, CONFIG.ringInlierClipFrac);
  if (clippedPts.length < 12) clippedPts = collectPointsFromIndices(cleanedStrokes, strokeIndices);

  // Flood fill is the single most expensive step (O(G²)). A ring can only be
  // CLOSED if its angular coverage is already near-complete, so skip the fill
  // entirely while the ring is still visibly open — the common case on every
  // intermediate stroke. When skipped the ring is open by definition.
  var flood;
  if (angGap.coverageRatio >= CONFIG.ringClosedCoverage * 0.9)
    flood = floodFillClosedness(floodStrokes, cx, cy, r);
  else
    flood = { closed: false, penetration: 1 };
  var neat   = measureRingNeatness(clippedPts, cx, cy, r);
  var nearInk = measureRingNearCircleInkRatio(cleanedStrokes, strokeIndices, cx, cy, r);

  var spanOk = angularSpanDeg(refitPts, cx, cy) >= CONFIG.ringMinAngularSpan
            || angGap.coverageRatio >= CONFIG.ringClosedCoverage * 0.92;

  var complete = flood.closed
              && angGap.coverageRatio >= CONFIG.ringClosedCoverage
              && nearInk >= CONFIG.ringMinNearCircleInk
              && spanOk;

  var allRingPts = collectPointsFromIndices(cleanedStrokes, strokeIndices);

  return {
    found:            true,
    complete:         complete,
    activationEvent:  false,
    strokeIndices:    strokeIndices,
    center:           { x: cx, y: cy },
    radius:           r,
    relResidual:      relResidual,
    floodPenetration: flood.penetration,
    coverageRatio:    angGap.coverageRatio,
    completeness:     complete ? 1 : angGap.coverageRatio,
    gapDeg:           angGap.gapDeg,
    roundness:        neat.roundness,
    smoothness:       neat.smoothness,
    neatness:         neat.neatness,
    nearCircleInkRatio: nearInk,
    overdrawAmount:   Math.max(0, pathLength(allRingPts) / (2 * Math.PI * r) - 1),
  };
}

function detectRing(cleanedStrokes, prevRing) {
  var arcInfos = [];
  for (var i = 0; i < cleanedStrokes.length; i++) {
    var arc = scoreArcCandidate(cleanedStrokes[i]);
    if (arc) arcInfos.push({ strokeIdx: i, arc: arc });
  }

  // Continue an in-progress ring even when the new stroke is a short closing arc
  // or a connector drawn slightly off the fitted circle. Seed from the previous
  // ring strokes, then let gatherRingStrokes() absorb any overlapping additions.
  if (prevRing && prevRing.found && prevRing.strokeIndices && prevRing.strokeIndices.length) {
    var pIdx = [];
    for (var pk = 0; pk < prevRing.strokeIndices.length; pk++)
      if (cleanedStrokes[prevRing.strokeIndices[pk]]) pIdx.push(prevRing.strokeIndices[pk]);

    var pPts = collectPointsFromIndices(cleanedStrokes, pIdx);
    var pFit = pPts.length >= 5 ? taubinCircleFit(pPts) : null;
    if (pFit) {
      var gathered = gatherRingStrokes(cleanedStrokes, pIdx, pFit.cx, pFit.cy, pFit.r);
      var eFit = gathered.fit.relResidual !== undefined ? gathered.fit
               : taubinCircleFit(collectPointsFromIndices(cleanedStrokes, gathered.indices));
      if (eFit && eFit.relResidual <= CONFIG.ringRelResidualMax) {
        var totalLen = 0;
        for (var ei = 0; ei < gathered.indices.length; ei++)
          totalLen += cleanedStrokes[gathered.indices[ei]].length;
        if (totalLen / (2 * Math.PI * eFit.r) >= CONFIG.ringMinLengthRatio * 0.85)
          return finalizeRingMeasurement(cleanedStrokes, gathered.indices, eFit, prevRing);
      }
    }
  }

  if (arcInfos.length === 0)
    return { found: false, complete: false, activationEvent: false, strokeIndices: [], completeness: 0 };

  var used = new Uint8Array(arcInfos.length);
  var clusters = [];

  for (var i = 0; i < arcInfos.length; i++) {
    if (used[i]) continue;
    var group = [i]; used[i] = 1;
    var refFit = arcInfos[i].arc.fit;

    for (var j = i + 1; j < arcInfos.length; j++) {
      if (used[j]) continue;
      var cFit = arcInfos[j].arc.fit;
      var refR = (refFit.r + cFit.r) / 2;
      var centerDist = Math.hypot(refFit.cx - cFit.cx, refFit.cy - cFit.cy);
      var radiusDiff  = Math.abs(refFit.r - cFit.r);
      if (centerDist < refR * CONFIG.arcMergeMaxCenterDistFrac &&
          radiusDiff  < refR * CONFIG.arcMergeMaxRadiusDiffFrac) {
        group.push(j); used[j] = 1;
      }
    }
    clusters.push(group);
  }

  var bestScore = -1;
  var bestCluster = null;
  var bestJointFit = null;

  for (var ci = 0; ci < clusters.length; ci++) {
    var group = clusters[ci];
    var allPts = [];
    for (var gi = 0; gi < group.length; gi++) {
      var pts = cleanedStrokes[arcInfos[group[gi]].strokeIdx].points;
      for (var pi = 0; pi < pts.length; pi++) allPts.push(pts[pi]);
    }

    var jFit = taubinCircleFit(allPts);
    if (!jFit) continue;
    if (jFit.relResidual > CONFIG.ringRelResidualMax) continue;

    var angPre = measureAngularGap(allPts, jFit.cx, jFit.cy, jFit.r);
    var span = angularSpanDeg(allPts, jFit.cx, jFit.cy);
    if (span < CONFIG.ringMinAngularSpan && angPre.coverageRatio < CONFIG.ringClosedCoverage * 0.90)
      continue;

    var totalLen = 0;
    for (var gi2 = 0; gi2 < group.length; gi2++)
      totalLen += cleanedStrokes[arcInfos[group[gi2]].strokeIdx].length;
    var lenRatio = totalLen / (2 * Math.PI * jFit.r);
    if (lenRatio < CONFIG.ringMinLengthRatio) continue;

    var score = jFit.r * (1 - jFit.relResidual) * Math.min(1.5, lenRatio) * (0.6 + angPre.coverageRatio * 0.4);
    if (score > bestScore) {
      bestScore     = score;
      bestCluster   = group;
      bestJointFit  = jFit;
    }
  }

  if (!bestCluster)
    return { found: false, complete: false, activationEvent: false, strokeIndices: [], completeness: 0 };

  var strokeIndices = bestCluster.map(function(gi) { return arcInfos[gi].strokeIdx; });
  return finalizeRingMeasurement(cleanedStrokes, strokeIndices, bestJointFit, prevRing);
}

// ─── FLOOD FILL CLOSEDNESS ─────────────────────────────────────────────────
// Rasterize the (inlier-clipped) ring points and flood-fill from outside.
// If the exterior cannot reach the center probe region, the ring is closed.

function measureAngularGapFromStrokes(strokes, cx, cy, r) {
  var N = CONFIG.ringGapBuckets;
  var buckets = new Uint8Array(N);
  for (var si = 0; si < strokes.length; si++)
    strokeNearCircleMetrics(strokes[si].points, cx, cy, r, buckets);

  var covered = 0;
  for (var i = 0; i < N; i++) if (buckets[i]) covered++;

  var maxGap = 0, cur = 0;
  for (var j = 0; j < N * 2; j++) {
    if (!buckets[j % N]) { cur++; if (cur > maxGap) maxGap = cur; }
    else cur = 0;
  }

  return { coverageRatio: covered / N, gapDeg: (maxGap / N) * 360 };
}

function floodFillClosedness(ringStrokes, cx, cy, r) {
  var G    = CONFIG.floodGridSize;
  var span = r * 1.55;
  var band = r * CONFIG.ringFloodInlierFrac;

  function wToG(wx, wy) {
    return {
      gx: Math.floor(((wx - (cx - span)) / (span * 2)) * G),
      gy: Math.floor(((wy - (cy - span)) / (span * 2)) * G),
    };
  }

  function stampAt(wx, wy, grid, thickness) {
    var g = wToG(wx, wy);
    for (var ddy = -thickness; ddy <= thickness; ddy++) {
      for (var ddx = -thickness; ddx <= thickness; ddx++) {
        if (ddx*ddx + ddy*ddy > thickness*thickness) continue;
        var nx = g.gx + ddx, ny = g.gy + ddy;
        if (nx >= 0 && nx < G && ny >= 0 && ny < G)
          grid[ny * G + nx] = 1;
      }
    }
  }

  var grid      = new Uint8Array(G * G);
  var thickness = Math.max(2, Math.round(G * CONFIG.floodInkThicknessPct));
  var pixWorld  = (span * 2) / G;
  var sampleStep = 2.0;

  for (var si = 0; si < ringStrokes.length; si++) {
    var pts = ringStrokes[si].points;
    for (var i = 1; i < pts.length; i++) {
      var dx = pts[i].x - pts[i-1].x;
      var dy = pts[i].y - pts[i-1].y;
      var segLen = Math.hypot(dx, dy);
      if (segLen <= 0) continue;
      var steps = Math.max(1, Math.ceil(segLen / sampleStep));
      for (var step = 1; step <= steps; step++) {
        var t = step / steps;
        var px = pts[i-1].x + dx * t;
        var py = pts[i-1].y + dy * t;
        var dist = Math.hypot(px - cx, py - cy);
        if (Math.abs(dist - r) > band) continue;
        var gSteps = Math.max(1, Math.ceil((segLen / steps) / pixWorld));
        stampAt(px, py, grid, thickness);
      }
    }
  }

  // Seed flood from all four edges
  var visited = new Uint8Array(G * G);
  var stack   = [];
  for (var x = 0; x < G; x++) {
    if (!grid[x]           && !visited[x])             { visited[x] = 1;             stack.push(x, 0); }
    if (!grid[(G-1)*G+x]   && !visited[(G-1)*G+x])     { visited[(G-1)*G+x] = 1;    stack.push(x, G-1); }
  }
  for (var y = 1; y < G - 1; y++) {
    if (!grid[y*G]         && !visited[y*G])            { visited[y*G] = 1;           stack.push(0, y); }
    if (!grid[y*G + G - 1] && !visited[y*G + G - 1])   { visited[y*G+G-1] = 1;       stack.push(G-1, y); }
  }

  var si = 0;
  while (si < stack.length) {
    var sx = stack[si++], sy = stack[si++];
    var nbrs = [sx-1,sy, sx+1,sy, sx,sy-1, sx,sy+1];
    for (var ni = 0; ni < 8; ni += 2) {
      var nx = nbrs[ni], ny = nbrs[ni+1];
      if (nx < 0 || nx >= G || ny < 0 || ny >= G) continue;
      var idx = ny * G + nx;
      if (visited[idx] || grid[idx]) continue;
      visited[idx] = 1;
      stack.push(nx, ny);
    }
  }

  var cg       = wToG(cx, cy);
  var rInGrid  = r * G / (span * 2);
  var innerR   = rInGrid * 0.45;
  var reached  = 0, total = 0;

  // Only scan the inner disk's bounding box, not the whole grid.
  var loY = Math.max(0, Math.floor(cg.gy - innerR)), hiY = Math.min(G - 1, Math.ceil(cg.gy + innerR));
  var loX = Math.max(0, Math.floor(cg.gx - innerR)), hiX = Math.min(G - 1, Math.ceil(cg.gx + innerR));
  var innerR2 = innerR * innerR;
  for (var gy = loY; gy <= hiY; gy++) {
    var ddy = gy - cg.gy;
    for (var gx = loX; gx <= hiX; gx++) {
      var ddx = gx - cg.gx;
      if (ddx * ddx + ddy * ddy <= innerR2) {
        total++;
        if (visited[gy * G + gx]) reached++;
      }
    }
  }

  var penetration = total > 0 ? reached / total : 0;
  return { closed: penetration <= CONFIG.floodPenetrationMax, penetration: penetration };
}

// ─── ANGULAR GAP (display only) ────────────────────────────────────────────

function measureAngularGap(pts, cx, cy, r) {
  var N    = CONFIG.ringGapBuckets;
  var band = r * CONFIG.ringInlierFrac;
  var buckets = new Uint8Array(N);

  for (var i = 0; i < pts.length; i++) {
    var d = Math.hypot(pts[i].x - cx, pts[i].y - cy);
    if (Math.abs(d - r) > band) continue;
    var a = Math.atan2(pts[i].y - cy, pts[i].x - cx);
    var b = Math.floor(((a + Math.PI) / (2 * Math.PI)) * N) % N;
    buckets[b] = 1;
  }

  var covered = 0;
  for (var i = 0; i < N; i++) if (buckets[i]) covered++;

  var maxGap = 0, cur = 0;
  for (var i = 0; i < N * 2; i++) {
    if (!buckets[i % N]) { cur++; if (cur > maxGap) maxGap = cur; }
    else cur = 0;
  }

  return { coverageRatio: covered / N, gapDeg: (maxGap / N) * 360 };
}

// ─── RING NEATNESS ─────────────────────────────────────────────────────────

function measureRingNeatness(pts, cx, cy, r) {
  if (pts.length < 3) return { roundness: 0, smoothness: 0, neatness: 0 };

  var totalDev = 0;
  for (var i = 0; i < pts.length; i++)
    totalDev += Math.abs(Math.hypot(pts[i].x - cx, pts[i].y - cy) - r);
  var avgDev    = totalDev / pts.length;
  var roundness = Math.max(0, 1 - avgDev / (r * 0.12));

  var cvSum = 0;
  for (var i = 1; i < pts.length - 1; i++) {
    var a1 = Math.atan2(pts[i].y   - cy, pts[i].x   - cx);
    var a0 = Math.atan2(pts[i-1].y - cy, pts[i-1].x - cx);
    var a2 = Math.atan2(pts[i+1].y - cy, pts[i+1].x - cx);
    var d  = angleDiffRad(a2, a1) - angleDiffRad(a1, a0);
    cvSum += d * d;
  }
  var smoothness = Math.max(0, 1 - Math.sqrt(cvSum / pts.length) * 2.5);

  return {
    roundness:  roundness,
    smoothness: smoothness,
    neatness:   roundness * 0.6 + smoothness * 0.4,
  };
}
