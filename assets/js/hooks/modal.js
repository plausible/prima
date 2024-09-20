export default {
  mounted() {
    this.el.addEventListener("livekit:modal:open", (e) => {
      this.maybeExecJS(this.el, "js-show");
      this.maybeExecJS(this.ref("modal-overlay"), "js-show");
      this.maybeExecJS(this.ref("modal-panel"), "js-show");
    });

    this.el.addEventListener("livekit:modal:close", (_e) => {
      this.maybeExecJS(this.ref("modal-overlay"), "js-hide");
      this.maybeExecJS(this.ref("modal-panel"), "js-hide");
    });

    this.ref("modal-overlay").addEventListener("phx:hide-end", (_e) => {
      this.maybeExecJS(this.el, "js-hide");
    });
  },

  maybeExecJS(el, attribute) {
    if (el && el.getAttribute(attribute)) {
      this.liveSocket.execJS(el, el.getAttribute(attribute));
    }
  },

  ref(ref) {
    return this.el.querySelector(`[livekit-ref="${ref}"]`);
  },
};
