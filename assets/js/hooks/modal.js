export default {
  mounted() {
    const overlay = this.el.querySelector('[livekit-ref="modal-overlay"]')
    const panel = this.el.querySelector('[livekit-ref="modal-panel"]')

    this.refs = { overlay, panel }

    this.el.addEventListener('livekit:modal:open', (e) => {
      liveSocket.execJS(this.el, this.el.getAttribute('js-show'))
      liveSocket.execJS(this.refs.overlay, this.refs.overlay.getAttribute("js-show"))
      this.maybeExecJS(this.refs.panel, "js-show")
    })

    this.el.addEventListener('livekit:modal:panel-mounted', (e) => {
      this.refs.panel = e.target
      this.maybeExecJS(this.refs.panel, "js-show")
    })

    this.el.addEventListener("livekit:modal:close", (e) => {
      liveSocket.execJS(this.refs.overlay, this.refs.overlay.getAttribute("js-hide"))
      this.maybeExecJS(this.refs.panel, "js-hide")
    })

    this.refs.overlay.addEventListener('phx:hide-end', (e) => {
      liveSocket.execJS(this.el, this.el.getAttribute('js-hide'))
    })
  },

  maybeExecJS(el, attribute) {
    if (el && el.getAttribute(attribute)) {
      console.log('executing')
      this.liveSocket.execJS(el, el.getAttribute(attribute))
    }
  }
}
