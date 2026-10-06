import PopoverController from '../popover.js'

const KEYS = {
  ARROW_UP: 'ArrowUp',
  ARROW_DOWN: 'ArrowDown',
  ENTER: 'Enter',
  SPACE: ' ',
  HOME: 'Home',
  END: 'End',
  PAGE_UP: 'PageUp',
  PAGE_DOWN: 'PageDown'
}

const SELECTORS = {
  BUTTON: '[aria-haspopup="menu"]',
  MENU_WRAPPER: '[data-prima-ref="menu-wrapper"]',
  MENU: '[role="menu"]',
  MENUITEM: '[role="menuitem"]',
  ENABLED_MENUITEM: '[role="menuitem"]:not([aria-disabled="true"])',
  FOCUSED_MENUITEM: '[role="menuitem"][data-focus]'
}

export default {
  mounted() {
    this.initialize()
    this.js().setAttribute(this.el, 'data-prima-ready', 'true')
  },

  beforeUpdate() {
    this.popover.captureFocus()
  },

  updated() {
    this.initialize()
    this.setFocus(this.el.querySelector(SELECTORS.FOCUSED_MENUITEM))
  },

  reconnected() {
    this.initialize()
  },

  destroyed() {
    this.cleanup()
    this.popover?.destroy()
  },

  initialize() {
    this.cleanup()
    this.setupElements()
    this.setupPopover()
    this.setupEventListeners()
  },

  setupElements() {
    const button = this.el.querySelector(SELECTORS.BUTTON)
    const menuWrapper = this.el.querySelector(SELECTORS.MENU_WRAPPER)
    const menu = this.el.querySelector(SELECTORS.MENU)

    this.setupAriaRelationships(button, menu)
    this.refs = { button, menuWrapper, menu }
  },

  setupPopover() {
    this.popover ||= new PopoverController(this, {
      initialFocus: () => this.refs.menu,
      onClose: () => this.clearFocus()
    })
    this.popover.update({
      trigger: this.refs.button,
      wrapper: this.refs.menuWrapper,
      panel: this.refs.menu
    })
  },

  setupEventListeners() {
    this.listeners = [
      [this.refs.button, 'click', () => this.popover.toggle()],
      [this.refs.menu, 'mouseover', this.handleMouseOver.bind(this)],
      [this.refs.menu, 'click', this.handleMenuClick.bind(this)],
      [this.el, 'keydown', this.handleKeydown.bind(this)]
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

    if (!this.popover.isOpen && document.activeElement === this.refs.button) {
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

    if (!this.popover.isOpen && document.activeElement === this.refs.button) {
      this.showMenuAndFocusFirst()
      return
    }

    const items = this.getEnabledMenuItems()
    if (items.length === 0) return

    const currentIndex = this.getCurrentFocusIndex(items)
    const targetIndex = currentIndex === items.length - 1 ? 0 : currentIndex + 1
    this.setFocus(items[targetIndex])
  },

  handleEnterOrSpace(e) {
    const focusedItem = this.popover.isOpen ? this.el.querySelector(SELECTORS.FOCUSED_MENUITEM) : null

    if (focusedItem && focusedItem.getAttribute('aria-disabled') !== 'true') {
      // A menu item is focused - click it
      e.preventDefault()
      focusedItem.click()
    } else if (document.activeElement === this.refs.button) {
      // Button is focused - open menu
      e.preventDefault()
      this.showMenuAndFocusFirst()
    }
  },

  handleHome(e) {
    if (this.popover.isOpen) {
      e.preventDefault()
      const items = this.getEnabledMenuItems()
      if (items.length > 0) {
        this.setFocus(items[0])
      }
    }
  },

  handleEnd(e) {
    if (this.popover.isOpen) {
      e.preventDefault()
      const items = this.getEnabledMenuItems()
      if (items.length > 0) {
        this.setFocus(items[items.length - 1])
      }
    }
  },

  handleTypeahead(e) {
    if (!this.popover.isOpen || e.key.length !== 1 || !/[a-zA-Z0-9]/.test(e.key)) return

    e.preventDefault()

    const searchChar = e.key.toLowerCase()
    const items = this.getEnabledMenuItems()
    const matchingItems = Array.from(items).filter(item =>
      item.textContent.trim().toLowerCase().startsWith(searchChar)
    )

    if (matchingItems.length === 0) return

    const currentFocused = this.el.querySelector(SELECTORS.FOCUSED_MENUITEM)
    const currentIndex = currentFocused && matchingItems.includes(currentFocused)
      ? matchingItems.indexOf(currentFocused)
      : -1

    const nextIndex = currentIndex >= 0 && currentIndex < matchingItems.length - 1
      ? currentIndex + 1
      : 0

    this.setFocus(matchingItems[nextIndex])
  },

  handleMouseOver(e) {
    if (!this.popover.isOpen) return
    const item = e.target.closest(SELECTORS.MENUITEM)
    if (item && item.getAttribute('aria-disabled') !== 'true') {
      this.setFocus(item)
    }
  },

  handleMenuClick(e) {
    if (!this.popover.isOpen) return
    const item = e.target.closest(SELECTORS.MENUITEM)
    if (item && item.getAttribute('aria-disabled') !== 'true') {
      this.popover.close('selection')
    }
  },

  getEnabledMenuItems() {
    return this.el.querySelectorAll(SELECTORS.ENABLED_MENUITEM)
  },

  getCurrentFocusIndex(items) {
    return Array.prototype.findIndex.call(items, item => item.hasAttribute('data-focus'))
  },

  setFocus(el) {
    this.clearFocus()
    if (el && el.getAttribute('aria-disabled') !== 'true') {
      this.js().setAttribute(el, 'data-focus', '')
      this.js().setAttribute(this.refs.menu, 'aria-activedescendant', el.id)
    }
  },

  clearFocus() {
    const focused = this.el.querySelector(SELECTORS.FOCUSED_MENUITEM)
    if (focused) this.js().removeAttribute(focused, 'data-focus')
    this.js().removeAttribute(this.refs.menu, 'aria-activedescendant')
  },

  showMenuAndFocusFirst() {
    this.popover.open()
    this.setFocus(this.getEnabledMenuItems()[0])
  },

  showMenuAndFocusLast() {
    this.popover.open()
    const items = this.getEnabledMenuItems()
    this.setFocus(items[items.length - 1])
  },

  setupAriaRelationships(button, menu) {
    this.js().setAttribute(button, 'aria-controls', menu.id)
    this.js().setAttribute(menu, 'aria-labelledby', button.id)

    this.setupSectionLabels()
  },

  setupSectionLabels() {
    const sections = this.el.querySelectorAll('[role="group"]')

    sections.forEach((section) => {
      // Check if the first child is a heading (role="presentation")
      const firstChild = section.firstElementChild
      if (firstChild && firstChild.getAttribute('role') === 'presentation') {
        // Link the section to the heading
        this.js().setAttribute(section, 'aria-labelledby', firstChild.id)
      }
    })
  }
}
