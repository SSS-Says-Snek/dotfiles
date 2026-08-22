// SpellTemplateExport.js — Authoring helper: turn raw drawn strokes into a
// sigils.json / signs.json dictionary entry. Used by TemplateEditor.qml.
.import "SpellCore.js" as Core

var normalizeStrokesForTemplate = Core.normalizeStrokesForTemplate;

function buildDictionaryEntry(kind, meta, rawStrokeArrays, options) {
  var tmpl = normalizeStrokesForTemplate(rawStrokeArrays, options);
  var entry = {
    id: meta.id,
    displayName: meta.displayName || meta.id,
    allowedLayers: meta.allowedLayers || (kind === 'sign' ? ['middle', 'outer'] : ['center', 'middle', 'outer']),
    strokeTemplate: tmpl,
  };
  if (kind === 'sigil') {
    entry.element = meta.element || 'fire';
    entry.recognitionRotationInvariant = !!meta.recognitionRotationInvariant;
    entry.semantic = meta.semantic || { force: 0.08, focus: 0.08, spread: 0.05, range: 0.08, lifetimeBias: 0.05 };
  } else {
    entry.semantic = meta.semantic || { manifestation: meta.id, directionMode: 'inward', force: 0, focus: 0, spread: 0, range: 0, lifetimeBias: 0 };
    if (meta.sourceNotes) entry.sourceNotes = meta.sourceNotes;
  }
  return entry;
}
