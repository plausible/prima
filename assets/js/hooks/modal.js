export default {
  mounted() {
    this.initialize()
  },

  updated() {
    this.initialize()
  },

  reconnected() {
    this.initialize()
  },

  destroyed() {
    this.cleanup()
  },

  initialize() {
    this.cleanup()
    this.setupElements()
    this.setupDOMEventListeners()
    this.setupPushEventListeners()
    this.checkInitialShow()
    this.el.setAttribute('data-prima-ready', 'true')
  },

  setupPushEventListeners() {
    this.pushEventRefs = [
      this.handleEvent("prima:modal:open", (payload) => {
        if (!payload.id || payload.id === this.el.id) {
          this.handleModalOpen()
        }
      }),
      this.handleEvent("prima:modal:close", (payload) => {
        if (!payload.id || payload.id === this.el.id) {
          this.handleModalClose()
        }
      })
    ]
  },

  setupElements() {
    // Check if this hook is attached to a portal or directly to the modal
    // The modal element has role="dialog", the portal wrapper does not
    if (this.el.getAttribute('role') === 'dialog') {
      // Non-portal mode: the hook element IS the modal
      this.modalEl = this.el
    } else {
      // Portal mode: find the actual modal element inside the portal
      this.modalEl = document.getElementById(this.el.id.replace('-portal', ''))

      if (!this.modalEl) {
        throw new Error(`[Prima Modal] Could not find modal element for portal ${this.el.id}`)
      }
    }

    if (!this.ref("modal-panel")) {
      this.async = true
    }
    this.setupAriaRelationships()
  },

  setupDOMEventListeners() {
    this.listeners = [
      [this.el, "prima:modal:open", this.handleModalOpen.bind(this)],
      [this.el, "prima:modal:close", this.handleModalClose.bind(this)],
      [this.ref("modal-overlay"), "phx:hide-end", this.handleOverlayHideEnd.bind(this)]
    ]

    if (this.async) {
      this.listeners.push(
        [this.el, "prima:modal:panel-mounted", this.handlePanelMounted.bind(this)],
        [this.el, "prima:modal:panel-removed", this.handlePanelRemoved.bind(this)]
      )
    }

    // Focus management - when panel is shown, focus first element
    if (this.ref("modal-panel")) {
      this.listeners.push(
        [this.ref("modal-panel"), "phx:show-end", this.handlePanelShowEnd.bind(this)]
      )
    }

    this.listeners.forEach(([element, event, handler]) => {
      if (element) {
        element.addEventListener(event, handler)
      }
    })
  },

  cleanup() {
    if (this.listeners) {
      this.listeners.forEach(([element, event, handler]) => {
        element.removeEventListener(event, handler)
      })
      this.listeners = []
    }

    if (this.pushEventRefs) {
      this.pushEventRefs.forEach(ref => {
        if (ref) this.removeHandleEvent(ref)
      })
      this.pushEventRefs = []
    }
  },

  checkInitialShow() {
    if (Object.hasOwn(this.el.dataset, 'primaShow')) {
      this.el.dispatchEvent(new Event('prima:modal:open'))
    }
  },

  handleModalOpen() {
    this.storeFocusedElement()
    this.preventBodyScroll()
    this.el.removeAttribute('aria-hidden')
    this.maybeExecJS(this.el, "js-show");
    this.maybeExecJS(this.ref("modal-overlay"), "js-show");
    if (this.async) {
      this.maybeExecJS(this.ref("modal-loader"), "js-show");
    } else {
      this.maybeExecJS(this.ref("modal-panel"), "js-show");
    }
  },

  handlePanelMounted() {
    this.maybeExecJS(this.ref("modal-loader"), "js-hide");
    this.maybeExecJS(this.ref("modal-panel"), "js-show");
    this.setupAriaRelationships()
    this.el.removeAttribute('aria-hidden')

    const panelShowEndHandler = this.handlePanelShowEnd.bind(this)
    this.ref("modal-panel").addEventListener("phx:show-end", panelShowEndHandler);
    this.listeners.push([this.ref("modal-panel"), "phx:show-end", panelShowEndHandler])
  },

  handlePanelRemoved() {
    if (!this.panelIsDirty()) {
      this.el.dispatchEvent(new Event('prima:modal:close'))
    }
  },

  handleModalClose() {
    this.restoreBodyScroll()
    this.maybeExecJS(this.ref("modal-overlay"), "js-hide");
    this.maybeExecJS(this.ref("modal-panel"), "js-hide");
    this.maybeExecJS(this.ref("modal-loader"), "js-hide");
    if (this.async) {
      this.ref("modal-panel").dataset.primaDirty = true
    }
  },

  handleOverlayHideEnd() {
    this.maybeExecJS(this.el, "js-hide");
    this.el.setAttribute('aria-hidden', 'true')
    this.restoreFocusedElement()
  },

  handlePanelShowEnd() {
    this.focusFirstElement()
  },

  maybeExecJS(el, attribute) {
    if (el && el.getAttribute(attribute)) {
      this.liveSocket.execJS(el, el.getAttribute(attribute));
    }
  },

  panelIsDirty() {
    return this.ref('modal-panel') && this.ref("modal-panel").dataset.primaDirty
  },

  ref(ref) {
    return this.el.querySelector(`[data-prima-ref="${ref}"]`);
  },

  preventBodyScroll() {
    this.originalBodyOverflow = document.body.style.overflow
    this.originalBodyPaddingRight = document.body.style.paddingRight

    const scrollBarWidth = window.innerWidth - document.documentElement.clientWidth
    document.body.style.overflow = 'hidden'
    document.body.style.paddingRight = scrollBarWidth + 'px'
  },

  restoreBodyScroll() {
    document.body.style.overflow = this.originalBodyOverflow || ''
    document.body.style.paddingRight = this.originalBodyPaddingRight || ''
  },

  setupAriaRelationships() {
    const modalId = this.el.id
    const titleElement = this.ref('modal-title')

    if (titleElement) {
      // Generate ID for the title if it doesn't have one
      if (!titleElement.id) {
        titleElement.id = `${modalId}-title`
      }

      // Set aria-labelledby on the modal container
      this.el.setAttribute('aria-labelledby', titleElement.id)
    }
  },

  storeFocusedElement() {
    this.previouslyFocusedElement = document.activeElement
  },

  restoreFocusedElement() {
    if (this.previouslyFocusedElement && this.previouslyFocusedElement.focus) {
      this.previouslyFocusedElement.focus()
    }
  },

  focusFirstElement() {
    const panel = this.ref("modal-panel")

    // First, check if there's an element with data-autofocus
    const autofocusElement = panel.querySelector('[data-autofocus]')
    if (autofocusElement) {
      autofocusElement.focus()
    } else {
      this.maybeExecJS(panel, 'js-focus-first')
    }
  }
};
