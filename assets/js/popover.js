import { computePosition, flip, offset, autoUpdate } from '@floating-ui/dom'

// Internal lifecycle shared by anchored popups. Selection and active-option
// policies belong to the hooks; logical openness never depends on an animation.
export default class PopoverController {
  constructor(hook, { initialFocus, onClose, onOpened }) {
    this.hook = hook
    this.initialFocus = initialFocus
    this.onClose = onClose
    this.onOpened = onOpened
    this.isOpen = false
    this.listeners = []
    this.setupDismissal()
    this.setupTransitions()
  }

  update({ trigger, wrapper, panel }) {
    const referenceSelector = wrapper.getAttribute('data-reference')
    const reference = (referenceSelector && document.querySelector(referenceSelector)) || trigger
    if (this.reference !== reference || this.wrapper !== wrapper) this.stopPositioning()
    this.trigger = trigger
    this.wrapper = wrapper
    this.panel = panel
    this.reference = reference

    this.syncAttributes()
    this.syncDisplay()
    if (this.isOpen) this.startPositioning()
  }

  setupDismissal() {
    this.listen(document, 'click', event => {
      if (!this.contains(event.target)) this.close('outside')
    })
    this.listen(this.hook.el, 'focusout', event => {
      if (event.relatedTarget && !this.contains(event.relatedTarget)) this.close('focus-out')
    })
    this.listen(this.hook.el, 'keydown', event => {
      if (!this.isOpen || event.defaultPrevented || event.isComposing) return
      if (event.key === 'Escape') {
        event.preventDefault()
        event.stopPropagation()
        this.close('escape')
      } else if (event.key === 'Tab' && this.contains(event.target)) {
        // Anchor the browser's next/previous Tab step before making the panel inert.
        this.trigger.focus({ preventScroll: true })
        this.close('tab')
      }
    })
  }

  setupTransitions() {
    // LiveView transition events do not bubble; capture them on the stable hook root.
    const onPanel = handler => event => {
      if (event.target === this.panel) handler()
    }
    this.listen(this.hook.el, 'phx:show-start', onPanel(() => {
      this.panel.style.display = this.isOpen ? 'block' : 'none'
      if (this.isOpen) this.initialFocus?.().focus({ preventScroll: true })
    }), true)
    this.listen(this.hook.el, 'phx:show-end', onPanel(() => {
      this.syncDisplay()
      if (this.isOpen) this.onOpened?.()
    }), true)
    this.listen(this.hook.el, 'phx:hide-end', onPanel(() => this.syncDisplay()), true)
  }

  // Preserve the original hooks' basic display correction after LiveView commands.
  syncDisplay() {
    this.wrapper.style.display = this.panel.style.display = this.isOpen ? 'block' : 'none'
    if (!this.isOpen) this.stopPositioning()
  }

  listen(element, event, handler, capture = false) {
    element.addEventListener(event, handler, capture)
    this.listeners.push([element, event, handler, capture])
  }

  contains(target) {
    return target && (this.trigger.contains(target) || this.panel.contains(target))
  }

  syncAttributes() {
    const js = this.hook.js()
    js.setAttribute(this.trigger, 'aria-expanded', String(this.isOpen))
    if (this.isOpen) {
      js.removeAttribute(this.panel, 'inert')
      js.removeAttribute(this.panel, 'aria-hidden')
    } else {
      js.setAttribute(this.panel, 'inert', '')
      js.setAttribute(this.panel, 'aria-hidden', 'true')
    }
  }

  toggle() {
    if (this.isOpen) this.close('trigger')
    else this.open()
  }

  open() {
    if (this.isOpen || this.trigger.disabled) return
    this.isOpen = true
    this.syncAttributes()
    this.wrapper.style.display = 'block'
    this.startPositioning()
    this.hook.liveSocket.execJS(this.panel, this.panel.getAttribute('js-show'))
  }

  close(reason = 'programmatic') {
    if (!this.isOpen) return
    this.isOpen = false
    this.focusFinal(reason)
    // Never leave DOM focus in the subtree that is about to become inert.
    if (this.panel.contains(document.activeElement)) document.activeElement.blur()
    this.syncAttributes()
    this.onClose()

    this.hook.liveSocket.execJS(this.panel, this.panel.getAttribute('js-hide'))
  }

  focusFinal(reason) {
    if (reason === 'focus-out' || reason === 'tab') return
    const active = document.activeElement
    if (active !== document.body && !this.contains(active)) return
    this.trigger.focus({ preventScroll: true })
  }

  startPositioning() {
    if (this.autoUpdateCleanup) this.position()
    else this.autoUpdateCleanup = autoUpdate(this.reference, this.wrapper, () => this.position())
  }

  position() {
    const { wrapper, reference } = this
    const middleware = []
    const distance = parseInt(wrapper.getAttribute('data-offset'), 10)
    if (!Number.isNaN(distance)) middleware.push(offset(distance))
    if (wrapper.getAttribute('data-flip') !== 'false') middleware.push(flip())
    wrapper.style.setProperty('--reference-width', `${reference.offsetWidth}px`)

    computePosition(reference, wrapper, {
      placement: wrapper.getAttribute('data-placement'),
      middleware
    }).then(({ x, y }) => {
      Object.assign(wrapper.style, { top: `${y}px`, left: `${x}px` })
    }).catch(error => console.error('[Prima Popover] Failed to position popup:', error))
  }

  stopPositioning() {
    this.autoUpdateCleanup?.()
    this.autoUpdateCleanup = null
  }

  destroy() {
    this.stopPositioning()
    this.listeners.forEach(([element, event, handler, capture]) => element.removeEventListener(event, handler, capture))
  }
}
