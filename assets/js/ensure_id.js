// Preserve server IDs and sticky client IDs when keyed LiveView nodes move.
// A new node's preferred ID may already belong to a surviving or custom element.
export function ensureId(el, preferredId, js) {
  if (el.id) return el.id

  let id = preferredId
  let suffix = 1
  while (el.ownerDocument.getElementById(id)) {
    id = `${preferredId}-${suffix++}`
  }

  js.setAttribute(el, 'id', id)
  return id
}
