export default {
  mounted() {
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
    this.setupEventListeners()
    this.checkInitialShow()
  },

  setupElements() {
    this.modalEl = document.getElementById(this.el.id.replace('-portal', ''))

    if (!this.modalEl) {
      throw new Error(`[Prima Modal] Could not find modal element for portal ${this.el.id}`)
    }

    if (!this.ref("modal-panel")) {
      this.async = true
    }
    this.setupAriaRelationships()
  },

  setupEventListeners() {
    this.listeners = [
      [this.modalEl, "prima:modal:open", this.handleModalOpen.bind(this)],
      [this.modalEl, "prima:modal:close", this.handleModalClose.bind(this)],
      [this.ref("modal-overlay"), "phx:hide-end", this.handleOverlayHideEnd.bind(this)]
    ]

    if (this.async) {
      this.listeners.push(
        [this.modalEl, "prima:modal:panel-mounted", this.handlePanelMounted.bind(this)],
        [this.modalEl, "prima:modal:panel-removed", this.handlePanelRemoved.bind(this)]
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
  },

  checkInitialShow() {
    if (Object.hasOwn(this.modalEl.dataset, 'primaShow')) {
      this.modalEl.dispatchEvent(new Event('prima:modal:open'))
    }
  },

  handleModalOpen() {
    this.log("modal:open")
    this.storeFocusedElement()
    this.preventBodyScroll()
    this.modalEl.removeAttribute('aria-hidden')
    this.maybeExecJS(this.modalEl, "js-show");
    this.maybeExecJS(this.ref("modal-overlay"), "js-show");
    if (this.async) {
      this.maybeExecJS(this.ref("modal-loader"), "js-show");
    } else {
      this.maybeExecJS(this.ref("modal-panel"), "js-show");
    }
  },

  handlePanelMounted() {
    this.log("modal:panel-mounted")
    this.maybeExecJS(this.ref("modal-loader"), "js-hide");
    this.maybeExecJS(this.ref("modal-panel"), "js-show");
    this.setupAriaRelationships()
    this.modalEl.removeAttribute('aria-hidden')

    const panelShowEndHandler = this.handlePanelShowEnd.bind(this)
    this.ref("modal-panel").addEventListener("phx:show-end", panelShowEndHandler);
    this.listeners.push([this.ref("modal-panel"), "phx:show-end", panelShowEndHandler])
  },

  handlePanelRemoved() {
    this.log("modal:panel-removed")
    if (!this.panelIsDirty()) {
      this.modalEl.dispatchEvent(new Event('prima:modal:close'))
    }
  },

  handleModalClose() {
    this.log("modal:close")
    this.restoreBodyScroll()
    this.maybeExecJS(this.ref("modal-overlay"), "js-hide");
    this.maybeExecJS(this.ref("modal-panel"), "js-hide");
    this.maybeExecJS(this.ref("modal-loader"), "js-hide");
    if (this.async) {
      this.ref("modal-panel").dataset.primaDirty = true
    }
  },

  handleOverlayHideEnd() {
    this.log("modal:overlay-hide-end")
    this.maybeExecJS(this.modalEl, "js-hide");
    this.modalEl.setAttribute('aria-hidden', 'true')
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
    return this.modalEl.querySelector(`[prima-ref="${ref}"]`);
  },

  log(message) {
    console.log(`[Prima ${this.el.id}] ${message}`)
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
    const modalId = this.modalEl.id
    const titleElement = this.ref('modal-title')

    if (titleElement) {
      // Generate ID for the title if it doesn't have one
      if (!titleElement.id) {
        titleElement.id = `${modalId}-title`
      }

      // Set aria-labelledby on the modal container
      this.modalEl.setAttribute('aria-labelledby', titleElement.id)
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
    const focusableElements = this.ref("modal-panel").querySelectorAll(
      'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])'
    )

    if (focusableElements.length > 0) {
      focusableElements[0].focus()
    }
  }
};
