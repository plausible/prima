export default {
  mounted() {
    if (!this.ref("modal-panel")) {
      this.async = true
    }

    this.setupAriaRelationships()

    this.el.addEventListener("prima:modal:open", (_e) => {
      this.log("modal:open")
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
    });

    if (this.async) {
      this.el.addEventListener("prima:modal:panel-mounted", (_e) => {
        this.log("modal:panel-mounted")
        this.maybeExecJS(this.ref("modal-loader"), "js-hide");
        this.maybeExecJS(this.ref("modal-panel"), "js-show");
        // Set up ARIA relationships for async modal since title element is now available
        this.setupAriaRelationships()
        // Ensure aria-hidden is removed for async modals 
        this.el.removeAttribute('aria-hidden')
        
        // Set up focus management for the async panel
        this.ref("modal-panel").addEventListener("phx:show-end", (_e) => {
          this.focusFirstElement()
        });
      })

      this.el.addEventListener("prima:modal:panel-removed", (_e) => {
        this.log("modal:panel-removed")
        if (!this.panelIsDirty()) {
          this.el.dispatchEvent(new Event('prima:modal:close'))
        }
      });
    }

    this.el.addEventListener("prima:modal:close", (_e) => {
      this.log("modal:close")
      this.restoreBodyScroll()
      this.maybeExecJS(this.ref("modal-overlay"), "js-hide");
      this.maybeExecJS(this.ref("modal-panel"), "js-hide");
      this.maybeExecJS(this.ref("modal-loader"), "js-hide");
      if (this.async) {
        this.ref("modal-panel").dataset.primaDirty = true
      }
    });

    this.ref("modal-overlay").addEventListener("phx:hide-end", (_e) => {
      this.log("modal:overlay-hide-end")
      this.maybeExecJS(this.el, "js-hide");
      this.el.setAttribute('aria-hidden', 'true')
      this.restoreFocusedElement()
    });

    // Focus management - when panel is shown, focus first element
    if (this.ref("modal-panel")) {
      this.ref("modal-panel").addEventListener("phx:show-end", (_e) => {
        this.focusFirstElement()
      });
    }

    if (Object.hasOwn(this.el.dataset, 'primaShow')) {
      this.el.dispatchEvent(new Event('prima:modal:open'))
    }
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
    return this.el.querySelector(`[prima-ref="${ref}"]`);
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
    const focusableElements = this.ref("modal-panel").querySelectorAll(
      'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])'
    )
    
    if (focusableElements.length > 0) {
      focusableElements[0].focus()
    }
  }
};
