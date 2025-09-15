export default {
  mounted() {
    this.initialize()
  },

  reconnected() {
    this.initialize()
  },

  destroyed() {
    this.cleanup()
  },

  initialize() {
    this.cleanup()
    this.setupElements()
    this.setupEventListeners()
  },

  setupElements() {
    const button = this.el.querySelector('[aria-haspopup="menu"]')
    const menu = this.el.querySelector('[role="menu"]')
    const items = this.el.querySelectorAll('[role="menuitem"]')

    this.setupAriaRelationships(button, menu)
    this.refs = { button, menu, items }
  },

  setupEventListeners() {
    this.listeners = [
      [this.refs.button, 'click', this.toggle.bind(this)],
      [this.refs.menu, 'mouseover', this.mouseOver.bind(this)],
      [this.el, 'keydown', this.onKey.bind(this)],
      [this.el, 'prima:close', this.close.bind(this)],
      [this.refs.menu, 'phx:show-start', () => this.refs.button.setAttribute('aria-expanded', 'true')],
      [this.refs.menu, 'phx:hide-end', () => {
        this.el.querySelector('[role=menuitem][data-focus]')?.removeAttribute('data-focus')
        this.refs.menu.removeAttribute('aria-activedescendant')
        this.refs.button.setAttribute('aria-expanded', 'false')
      }]
    ]

    this.listeners.forEach(([element, event, handler]) => {
      element.addEventListener(event, handler)
    })
  },

  cleanup() {
    if (this.listeners) {
      this.listeners.forEach(([element, event, handler]) => {
        element.removeEventListener(event, handler)
      })
      this.listeners = []
    }
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

    // Update aria-activedescendant to point to the active item
    this.refs.menu.setAttribute('aria-activedescendant', el.id)
  },

  mouseOver(e) {
    if (e.target.getAttribute('role') === 'menuitem') {
      this.setActive(e.target)
    }
  },

  setupAriaRelationships(button, menu) {
    const dropdownId = this.el.id
    const triggerId = `${dropdownId}-trigger`
    const menuId = `${dropdownId}-menu`

    button.id = triggerId
    button.setAttribute('aria-controls', menuId)
    menu.id = menuId
    menu.setAttribute('aria-labelledby', triggerId)

    // Set up menuitem IDs
    this.setupMenuitemIds()
  },

  setupMenuitemIds() {
    const dropdownId = this.el.id
    const items = this.el.querySelectorAll('[role="menuitem"]')

    items.forEach((item, index) => {
      item.id = `${dropdownId}-item-${index}`
    })
  }
}
