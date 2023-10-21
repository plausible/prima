export default {
  mounted() {
    const overlay = this.el.querySelector('[livekit-ref="modal-overlay"]')
    const panel = this.el.querySelector('[livekit-ref="modal-panel"]')

    this.refs = { overlay, panel }

    this.el.addEventListener('livekit:modal:open', (e) => {
      liveSocket.execJS(this.el, this.el.getAttribute('js-show'))
      liveSocket.execJS(this.refs.overlay, this.refs.overlay.getAttribute("js-show"))
      liveSocket.execJS(this.refs.panel, this.refs.panel.getAttribute("js-show"))
    })

    this.el.addEventListener("livekit:modal:close", (e) => {
      liveSocket.execJS(this.refs.overlay, this.refs.overlay.getAttribute("js-hide"))
      liveSocket.execJS(this.refs.panel, this.refs.panel.getAttribute("js-hide"))
    })

    this.refs.overlay.addEventListener('phx:hide-end', (e) => {
      liveSocket.execJS(this.el, this.el.getAttribute('js-hide'))
    })
  }
}
