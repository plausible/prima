export default {
  mounted() {
    if (!this.ref("modal-panel")) {
      this.async = true
    }

    this.el.addEventListener("livekit:modal:open", (e) => {
      this.log("modal:open")
      this.preventBodyScroll()
      this.maybeExecJS(this.el, "js-show");
      this.maybeExecJS(this.ref("modal-overlay"), "js-show");
      if (this.async) {
        this.maybeExecJS(this.ref("modal-loader"), "js-show");
      } else {
        this.maybeExecJS(this.ref("modal-panel"), "js-show");
      }
    });

    if (this.async) {
      this.el.addEventListener("livekit:modal:panel-mounted", (_e) => {
        this.log("modal:panel-mounted")
        this.maybeExecJS(this.ref("modal-loader"), "js-hide");
        this.maybeExecJS(this.ref("modal-panel"), "js-show");
      })

      this.el.addEventListener("livekit:modal:panel-removed", (_e) => {
        this.log("modal:panel-removed")
        if (!this.panelIsDirty()) {
          this.el.dispatchEvent(new Event('livekit:modal:close'))
        }
      });
    }

    this.el.addEventListener("livekit:modal:close", (_e) => {
      this.log("modal:close")
      this.restoreBodyScroll()
      this.maybeExecJS(this.ref("modal-overlay"), "js-hide");
      this.maybeExecJS(this.ref("modal-panel"), "js-hide");
      this.maybeExecJS(this.ref("modal-loader"), "js-hide");
      if (this.async) {
        this.ref("modal-panel").dataset.livekitDirty = true
      }
    });

    this.ref("modal-overlay").addEventListener("phx:hide-end", (_e) => {
      this.log("modal:overlay-hide-end")
      this.maybeExecJS(this.el, "js-hide");
    });

    if (Object.hasOwn(this.el.dataset, 'livekitShow')) {
      this.el.dispatchEvent(new Event('livekit:modal:open'))
    }
  },

  maybeExecJS(el, attribute) {
    if (el && el.getAttribute(attribute)) {
      this.liveSocket.execJS(el, el.getAttribute(attribute));
    }
  },

  panelIsDirty() {
    return this.ref('modal-panel') && this.ref("modal-panel").dataset.livekitDirty
  },

  ref(ref) {
    return this.el.querySelector(`[livekit-ref="${ref}"]`);
  },

  log(message) {
    console.log(`[Livekit ${this.el.id}] ${message}`)
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
  }
};
