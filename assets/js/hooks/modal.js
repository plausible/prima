export default {
  mounted() {
    this.el.addEventListener("livekit:modal:open", (e) => {
      this.maybeExecJS(this.el, "js-show");
      this.maybeExecJS(this.ref("modal-overlay"), "js-show");
      this.maybeExecJS(this.ref("modal-loader"), "js-show");
      if (!this.panelIsDirty()) {
        this.maybeExecJS(this.ref("modal-panel"), "js-show");
      }
    });

    this.el.addEventListener("livekit:modal:panel-mounted", (_e) => {
      this.maybeExecJS(this.ref("modal-panel"), "js-show");
      this.maybeExecJS(this.ref("modal-loader"), "js-hide");
      this.ref("modal-panel").dataset.livekitAsync = true
    })

    this.el.addEventListener("livekit:modal:close", (_e) => {
      this.maybeExecJS(this.ref("modal-overlay"), "js-hide");
      this.maybeExecJS(this.ref("modal-panel"), "js-hide");
      if (this.ref("modal-panel").dataset.livekitAsync) {
        this.ref("modal-panel").dataset.livekitDirty = true
      }
      this.maybeExecJS(this.ref("modal-loader"), "js-hide");
    });

    this.el.addEventListener("livekit:modal:panel-removed", (_e) => {
      if (!this.panelIsDirty()) {
        this.el.dispatchEvent(new Event('livekit:modal:close'))
      }
    });

    this.ref("modal-overlay").addEventListener("phx:hide-end", (_e) => {
      this.maybeExecJS(this.el, "js-hide");
    });

    if(Object.hasOwn(this.el.dataset, 'livekitShow')) {
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
};
