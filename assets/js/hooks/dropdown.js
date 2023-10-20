export default {
  mounted() {
    const button = this.el.querySelector('[aria-haspopup="menu"]')
    const menu = this.el.querySelector('[role="menu"]')
    const items = this.el.querySelectorAll('[role="menuitem"]')

    this.refs = {
      button,
      menu,
      items
    }

    button.addEventListener('click', this.toggle.bind(this))
  },

  toggle(e) {
    liveSocket.execJS(this.refs.menu, this.refs.menu.getAttribute("js-open"))
  }
}
