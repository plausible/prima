const KEYS = {
  ARROW_UP: 'ArrowUp',
  ARROW_DOWN: 'ArrowDown',
  ESCAPE: 'Escape'
}

const SELECTORS = {
  BUTTON: '[aria-haspopup="menu"]',
  MENU: '[role="menu"]',
  MENUITEM: '[role="menuitem"]',
  FOCUSED_MENUITEM: '[role="menuitem"][data-focus]'
}

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
    const button = this.el.querySelector(SELECTORS.BUTTON)
    const menu = this.el.querySelector(SELECTORS.MENU)
    const items = this.el.querySelectorAll(SELECTORS.MENUITEM)

    this.setupAriaRelationships(button, menu)
    this.refs = { button, menu, items }
  },

  setupEventListeners() {
    this.listeners = [
      [this.refs.button, 'click', this.handleToggle.bind(this)],
      [this.refs.menu, 'mouseover', this.handleMouseOver.bind(this)],
      [this.el, 'keydown', this.handleKeydown.bind(this)],
      [this.el, 'prima:close', this.handleClose.bind(this)],
      [this.refs.menu, 'phx:show-start', this.handleShowStart.bind(this)],
      [this.refs.menu, 'phx:hide-end', this.handleHideEnd.bind(this)]
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

  handleKeydown(e) {
    const keyHandlers = {
      [KEYS.ARROW_UP]: () => this.navigateUp(e),
      [KEYS.ARROW_DOWN]: () => this.navigateDown(e),
      [KEYS.ESCAPE]: () => this.handleEscape()
    }

    const handler = keyHandlers[e.key]
    if (handler) {
      handler()
    }
  },

  navigateUp(e) {
    e.preventDefault()
    const items = this.getAllMenuItems()
    const currentIndex = this.getCurrentFocusIndex(items)
    const targetIndex = currentIndex === 0 ? items.length - 1 : currentIndex - 1
    this.setActive(items[targetIndex])
  },

  navigateDown(e) {
    e.preventDefault()
    const items = this.getAllMenuItems()
    const currentIndex = this.getCurrentFocusIndex(items)
    const targetIndex = currentIndex === items.length - 1 ? 0 : currentIndex + 1
    this.setActive(items[targetIndex])
  },

  handleEscape() {
    this.hideMenu()
    this.refs.button.focus()
  },

  handleClose() {
    this.hideMenu()
  },

  handleToggle() {
    this.toggleMenu()
  },

  handleMouseOver(e) {
    if (e.target.getAttribute('role') === 'menuitem') {
      this.setActive(e.target)
    }
  },

  handleShowStart() {
    this.refs.button.setAttribute('aria-expanded', 'true')
  },

  handleHideEnd() {
    this.clearFocus()
    this.refs.menu.removeAttribute('aria-activedescendant')
    this.refs.button.setAttribute('aria-expanded', 'false')
  },

  getAllMenuItems() {
    return this.el.querySelectorAll(SELECTORS.MENUITEM)
  },

  getCurrentFocusIndex(items) {
    return Array.prototype.findIndex.call(items, item => item.hasAttribute('data-focus'))
  },

  setActive(el) {
    this.clearFocus()
    el.setAttribute('data-focus', '')
    this.refs.menu.setAttribute('aria-activedescendant', el.id)
  },

  clearFocus() {
    this.el.querySelector(SELECTORS.FOCUSED_MENUITEM)?.removeAttribute('data-focus')
  },

  hideMenu() {
    liveSocket.execJS(this.refs.menu, this.refs.menu.getAttribute('js-hide'))
  },

  toggleMenu() {
    liveSocket.execJS(this.refs.menu, this.refs.menu.getAttribute('js-toggle'))
  },

  setupAriaRelationships(button, menu) {
    const dropdownId = this.el.id
    const triggerId = `${dropdownId}-trigger`
    const menuId = `${dropdownId}-menu`

    button.id = triggerId
    button.setAttribute('aria-controls', menuId)
    menu.id = menuId
    menu.setAttribute('aria-labelledby', triggerId)

    this.setupMenuitemIds()
  },

  setupMenuitemIds() {
    const dropdownId = this.el.id
    const items = this.el.querySelectorAll(SELECTORS.MENUITEM)

    items.forEach((item, index) => {
      item.id = `${dropdownId}-item-${index}`
    })
  }
}
