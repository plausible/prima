export default {
  mounted() {
    const button = this.el.querySelector('[aria-haspopup="menu"]')
    const menu = this.el.querySelector('[role="menu"]')
    const items = this.el.querySelectorAll('[role="menuitem"]')

    this.refs = { button, menu, items }

    button.addEventListener('click', this.toggle.bind(this))
    menu.addEventListener('mouseover', this.mouseOver.bind(this))
    this.el.addEventListener('keydown', this.onKey.bind(this))
    this.el.addEventListener('livekit:close', this.close.bind(this))
    
    // Set up the hide-end event listener on mount
    this.refs.menu.addEventListener('phx:hide-end', () => {
      this.el.querySelector('[role=menuitem][data-focus]')?.removeAttribute('data-focus')
    })
  },

  onKey(e) {
    const allItems = Array.from(this.el.querySelectorAll('[role=menuitem]'))
    const firstItem = allItems[0]
    const lastItem = allItems[allItems.length - 1]
    const currentFocusIndex = allItems.findIndex(item => item.hasAttribute('data-focus'))

    if (e.key === "ArrowUp") {
      e.preventDefault()
      if (firstItem.hasAttribute('data-focus')) {
        this.setActive(lastItem)
      } else {
        this.setActive(allItems[currentFocusIndex - 1])
      }
    } else if (e.key === 'ArrowDown') {
      e.preventDefault()
      if (lastItem.hasAttribute('data-focus')) {
        this.setActive(firstItem)
      } else {
        this.setActive(allItems[currentFocusIndex + 1])
      }
    } else if (e.key === "Escape") {
      liveSocket.execJS(this.refs.menu, this.refs.menu.getAttribute("js-hide"))
      this.refs.button.focus()
    }
  },

  close() {
    liveSocket.execJS(this.refs.menu, this.refs.menu.getAttribute("js-hide"))
  },

  toggle() {
    liveSocket.execJS(this.refs.menu, this.refs.menu.getAttribute("js-toggle"))
  },

  setActive(el) {
    this.el.querySelector('[role=menuitem][data-focus]')?.removeAttribute('data-focus')
    el.setAttribute('data-focus', '')
  },

  mouseOver(e) {
    if (e.target.getAttribute('role') === 'menuitem') {
      this.setActive(e.target)
    }
  }
}
