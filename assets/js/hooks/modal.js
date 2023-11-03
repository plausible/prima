export default {
  mounted() {
    const overlay = this.el.querySelector('[livekit-ref="modal-overlay"]');
    const panel = this.el.querySelector('[livekit-ref="modal-panel"]');

    this.refs = { overlay, panel };
    this.el.addEventListener("livekit:modal:open", (e) => {
      liveSocket.execJS(this.el, this.el.getAttribute("js-show"));
      this.maybeExecJS(this.refs.overlay, "js-show");
      this.maybeExecJS(this.refs.panel, "js-show");
    });

    this.el.addEventListener("livekit:modal:panel-mounted", (e) => {
      this.refs.panel = e.target;
      this.maybeExecJS(this.refs.panel, "js-show");
    });

    // This is triggered via JS.dispatch
    this.el.addEventListener("livekit:modal:close", (_e) => {
      this.maybeExecJS(this.refs.overlay, "js-hide");
      this.maybeExecJS(this.refs.panel, "js-hide");
    });

    // This is triggered via push_event from backend
    this.handleEvent("livekit:modal:close", (_e) => {
      this.maybeExecJS(this.refs.overlay, "js-hide");
      this.maybeExecJS(this.refs.panel, "js-hide");
    });

    this.refs.overlay.addEventListener("phx:hide-end", (_e) => {
      liveSocket.execJS(this.el, this.el.getAttribute("js-hide"));
    });
  },

  maybeExecJS(el, attribute) {
    if (el && el.getAttribute(attribute)) {
      this.liveSocket.execJS(el, el.getAttribute(attribute));
    }
  },
};
