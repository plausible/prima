export default {
  mounted() {
    const button = this.el.querySelector('[aria-haspopup="menu"]')
    const menu = this.el.querySelector('[role="menu"]')
    const items = this.el.querySelectorAll('[role="menuitem"]')

    this.refs = { button, menu, items }
    this.activeItem = null

    button.addEventListener('click', this.toggle.bind(this))
    menu.addEventListener('mouseover', this.mouseOver.bind(this))
  },

  toggle(e) {
    liveSocket.execJS(this.refs.menu, this.refs.menu.getAttribute("js-toggle"))
  },

  mouseOver(e) {
    if (e.target.getAttribute('role') === 'menuitem') {
      this.activeItem && this.activeItem.setAttribute('livekit-state', '')
      e.target.setAttribute('livekit-state', 'active')
      this.activeItem = e.target
    }
  }
}
