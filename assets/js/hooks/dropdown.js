const KEYS = {
  ARROW_UP: 'ArrowUp',
  ARROW_DOWN: 'ArrowDown',
  ESCAPE: 'Escape',
  ENTER: 'Enter',
  SPACE: ' ',
  HOME: 'Home',
  END: 'End',
  PAGE_UP: 'PageUp',
  PAGE_DOWN: 'PageDown'
}

const SELECTORS = {
  BUTTON: '[aria-haspopup="menu"]',
  MENU: '[role="menu"]',
  MENUITEM: '[role="menuitem"]',
  ENABLED_MENUITEM: '[role="menuitem"]:not([aria-disabled="true"])',
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
    this.el.setAttribute('data-prima-ready', 'true')
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
      [this.refs.menu, 'click', this.handleMenuClick.bind(this)],
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
      [KEYS.ESCAPE]: () => this.handleEscape(),
      [KEYS.ENTER]: () => this.handleEnterOrSpace(e),
      [KEYS.SPACE]: () => this.handleEnterOrSpace(e),
      [KEYS.HOME]: () => this.handleHome(e),
      [KEYS.END]: () => this.handleEnd(e),
      [KEYS.PAGE_UP]: () => this.handleHome(e),
      [KEYS.PAGE_DOWN]: () => this.handleEnd(e)
    }

    const handler = keyHandlers[e.key]
    if (handler) {
      handler()
    } else {
      this.handleTypeahead(e)
    }
  },

  navigateUp(e) {
    e.preventDefault()

    if (!this.isMenuVisible() && document.activeElement === this.refs.button) {
      this.showMenuAndFocusLast()
      return
    }

    const items = this.getEnabledMenuItems()
    if (items.length === 0) return

    const currentIndex = this.getCurrentFocusIndex(items)
    const targetIndex = currentIndex === 0 ? items.length - 1 : currentIndex - 1
    this.setFocus(items[targetIndex])
  },

  navigateDown(e) {
    e.preventDefault()

    if (!this.isMenuVisible() && document.activeElement === this.refs.button) {
      this.showMenuAndFocusFirst()
      return
    }

    const items = this.getEnabledMenuItems()
    if (items.length === 0) return

    const currentIndex = this.getCurrentFocusIndex(items)
    const targetIndex = currentIndex === items.length - 1 ? 0 : currentIndex + 1
    this.setFocus(items[targetIndex])
  },

  handleEscape() {
    this.hideMenu()
    this.refs.button.focus()
  },

  handleEnterOrSpace(e) {
    if (document.activeElement === this.refs.button) {
      e.preventDefault()
      this.showMenuAndFocusFirst()
    }
  },

  handleHome(e) {
    if (this.isMenuVisible()) {
      e.preventDefault()
      const items = this.getEnabledMenuItems()
      if (items.length > 0) {
        this.setFocus(items[0])
      }
    }
  },

  handleEnd(e) {
    if (this.isMenuVisible()) {
      e.preventDefault()
      const items = this.getEnabledMenuItems()
      if (items.length > 0) {
        this.setFocus(items[items.length - 1])
      }
    }
  },

  handleTypeahead(e) {
    if (!this.isMenuVisible()) return

    // Check if it's a printable character (A-Z, a-z, 0-9)
    if (e.key.length === 1 && /[a-zA-Z0-9]/.test(e.key)) {
      e.preventDefault()

      const searchChar = e.key.toLowerCase()
      const items = this.getEnabledMenuItems()

      // Find all items that start with the typed character
      const matchingItems = []
      for (let item of items) {
        const itemText = item.textContent.trim().toLowerCase()
        if (itemText.startsWith(searchChar)) {
          matchingItems.push(item)
        }
      }

      if (matchingItems.length === 0) return

      // Check if currently focused item matches the search character
      const currentFocused = this.el.querySelector(SELECTORS.FOCUSED_MENUITEM)
      const shouldCycle = currentFocused &&
                         currentFocused.textContent.trim().toLowerCase().startsWith(searchChar) &&
                         matchingItems.includes(currentFocused)

      if (shouldCycle) {
        // Find the current item's index in matching items and cycle to next
        const currentIndex = matchingItems.indexOf(currentFocused)
        const nextIndex = (currentIndex + 1) % matchingItems.length
        this.setFocus(matchingItems[nextIndex])
      } else {
        // Focus the first matching item
        this.setFocus(matchingItems[0])
      }
    }
  },

  handleClose() {
    this.hideMenu()
  },

  handleToggle() {
    this.toggleMenu()
  },

  handleMouseOver(e) {
    if (e.target.getAttribute('role') === 'menuitem' &&
        e.target.getAttribute('aria-disabled') !== 'true') {
      this.setFocus(e.target)
    }
  },

  handleMenuClick(e) {
    if (e.target.getAttribute('role') === 'menuitem' &&
        e.target.getAttribute('aria-disabled') !== 'true') {
      this.hideMenu()
      this.refs.button.focus()
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

  getEnabledMenuItems() {
    return this.el.querySelectorAll(SELECTORS.ENABLED_MENUITEM)
  },

  isMenuVisible() {
    const menu = this.refs.menu
    return menu && menu.style.display !== 'none' && menu.offsetParent !== null
  },

  getCurrentFocusIndex(items) {
    return Array.prototype.findIndex.call(items, item => item.hasAttribute('data-focus'))
  },

  setFocus(el) {
    this.clearFocus()
    if (el && el.getAttribute('aria-disabled') !== 'true') {
      el.setAttribute('data-focus', '')
      this.refs.menu.setAttribute('aria-activedescendant', el.id)
    } else {
      this.refs.menu.removeAttribute('aria-activedescendant')
    }
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

  showMenuAndFocusFirst() {
    // Use toggle to show the menu (same as clicking the button)
    liveSocket.execJS(this.refs.menu, this.refs.menu.getAttribute('js-toggle'))

    // Focus the first enabled item after the menu appears
    const items = this.getEnabledMenuItems()
    if (items.length > 0) {
      this.setFocus(items[0])
    }
  },

  showMenuAndFocusLast() {
    // Use toggle to show the menu (same as clicking the button)
    liveSocket.execJS(this.refs.menu, this.refs.menu.getAttribute('js-toggle'))

    // Focus the last enabled item after the menu appears
    const items = this.getEnabledMenuItems()
    if (items.length > 0) {
      this.setFocus(items[items.length - 1])
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
