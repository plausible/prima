import { computePosition, flip, offset, autoUpdate } from '@floating-ui/dom';

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
  MENU_WRAPPER: '[data-prima-ref="menu-wrapper"]',
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

    // First try to find menu wrapper in the local element (for backwards compatibility)
    let menuWrapper = this.el.querySelector(SELECTORS.MENU_WRAPPER)
    let menu = this.el.querySelector(SELECTORS.MENU)

    // If not found locally, the menu is portaled - find it using the data-menu-id attribute
    if (!menuWrapper || !menu) {
      const menuId = this.el.getAttribute('data-menu-id')
      if (menuId) {
        // Find the menu by its ID in the portaled content
        menu = document.getElementById(menuId)
        if (menu) {
          menuWrapper = menu.closest(SELECTORS.MENU_WRAPPER)
        }
      }
    }

    const referenceSelector = menuWrapper?.getAttribute('data-reference')
    const referenceElement = referenceSelector ? document.querySelector(referenceSelector) : button

    this.setupAriaRelationships(button, menu)
    const items = menu ? menu.querySelectorAll(SELECTORS.MENUITEM) : []
    this.refs = { button, menuWrapper, menu, items, referenceElement }
  },

  setupEventListeners() {
    if (!this.refs || !this.refs.button || !this.refs.menu) {
      console.error('[Prima Dropdown] Cannot setup event listeners: refs not initialized', {
        dropdownId: this.el.id,
        refs: this.refs
      })
      return
    }

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
      if (element) {
        element.addEventListener(event, handler)
      }
    })
  },

  cleanup() {
    this.cleanupAutoUpdate()

    if (this.listeners) {
      this.listeners.forEach(([element, event, handler]) => {
        element.removeEventListener(event, handler)
      })
      this.listeners = []
    }
  },

  cleanupAutoUpdate() {
    if (this.autoUpdateCleanup) {
      this.autoUpdateCleanup()
      this.autoUpdateCleanup = null
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
    if (!this.isMenuVisible() || e.key.length !== 1 || !/[a-zA-Z0-9]/.test(e.key)) return

    e.preventDefault()

    const searchChar = e.key.toLowerCase()
    const items = this.getEnabledMenuItems()
    const matchingItems = Array.from(items).filter(item =>
      item.textContent.trim().toLowerCase().startsWith(searchChar)
    )

    if (matchingItems.length === 0) return

    const currentFocused = this.refs.menu ? this.refs.menu.querySelector(SELECTORS.FOCUSED_MENUITEM) : null
    const currentIndex = currentFocused && matchingItems.includes(currentFocused)
      ? matchingItems.indexOf(currentFocused)
      : -1

    const nextIndex = currentIndex >= 0 && currentIndex < matchingItems.length - 1
      ? currentIndex + 1
      : 0

    this.setFocus(matchingItems[nextIndex])
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

    // Setup autoUpdate to reposition on scroll/resize
    this.autoUpdateCleanup = autoUpdate(this.refs.referenceElement, this.refs.menuWrapper, () => {
      this.positionMenu()
    })
  },

  handleHideEnd() {
    this.clearFocus()
    this.refs.menu.removeAttribute('aria-activedescendant')
    this.refs.button.setAttribute('aria-expanded', 'false')
    this.refs.menuWrapper.style.display = 'none'
    this.cleanupAutoUpdate()
  },

  getAllMenuItems() {
    return this.refs.menu ? this.refs.menu.querySelectorAll(SELECTORS.MENUITEM) : []
  },

  getEnabledMenuItems() {
    return this.refs.menu ? this.refs.menu.querySelectorAll(SELECTORS.ENABLED_MENUITEM) : []
  },

  isMenuVisible() {
    const wrapper = this.refs.menuWrapper
    return wrapper && wrapper.style.display !== 'none' && wrapper.offsetParent !== null
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
    const focusedItem = this.refs.menu ? this.refs.menu.querySelector(SELECTORS.FOCUSED_MENUITEM) : null
    if (focusedItem) {
      focusedItem.removeAttribute('data-focus')
    }
  },

  hideMenu() {
    liveSocket.execJS(this.refs.menu, this.refs.menu.getAttribute('js-hide'))
    this.refs.menuWrapper.style.display = 'none'
  },

  toggleMenu() {
    if (this.isMenuVisible()) {
      liveSocket.execJS(this.refs.menu, this.refs.menu.getAttribute('js-hide'))
      this.refs.menuWrapper.style.display = 'none'
    } else {
      // Wrapper pattern: Show wrapper first (display:block) so Floating UI can measure it,
      // then position it, then trigger inner menu transition. This prevents the menu from
      // briefly appearing at wrong position before jumping to correct position.
      this.refs.menuWrapper.style.display = 'block'
      this.positionMenu()
      liveSocket.execJS(this.refs.menu, this.refs.menu.getAttribute('js-show'))
    }
  },

  showMenuAndFocusFirst() {
    // Show wrapper and position it
    this.refs.menuWrapper.style.display = 'block'
    this.positionMenu()

    // Use show to display the menu
    liveSocket.execJS(this.refs.menu, this.refs.menu.getAttribute('js-show'))

    // Focus the first enabled item after the menu appears
    const items = this.getEnabledMenuItems()
    if (items.length > 0) {
      this.setFocus(items[0])
    }
  },

  showMenuAndFocusLast() {
    // Show wrapper and position it
    this.refs.menuWrapper.style.display = 'block'
    this.positionMenu()

    // Use show to display the menu
    liveSocket.execJS(this.refs.menu, this.refs.menu.getAttribute('js-show'))

    // Focus the last enabled item after the menu appears
    const items = this.getEnabledMenuItems()
    if (items.length > 0) {
      this.setFocus(items[items.length - 1])
    }
  },

  setupAriaRelationships(button, menu) {
    if (!button || !menu) {
      console.error('[Prima Dropdown] Cannot setup ARIA relationships: button or menu is null', {
        dropdownId: this.el.id,
        button: button,
        menu: menu
      })
      return
    }

    const dropdownId = this.el.id
    const triggerId = `${dropdownId}-trigger`
    // Use the menu's existing ID if it has one, otherwise generate one
    const menuId = menu.id || `${dropdownId}-menu`

    button.id = triggerId
    button.setAttribute('aria-controls', menuId)
    // Only set menu ID if it doesn't have one already
    if (!menu.id) {
      menu.id = menuId
    }
    menu.setAttribute('aria-labelledby', triggerId)

    this.setupMenuitemIds()
  },

  setupMenuitemIds() {
    const dropdownId = this.el.id
    const items = this.refs.menu ? this.refs.menu.querySelectorAll(SELECTORS.MENUITEM) : []

    items.forEach((item, index) => {
      item.id = `${dropdownId}-item-${index}`
    })
  },

  positionMenu() {
    if (!this.refs.menuWrapper) return

    const placement = this.refs.menuWrapper.getAttribute('data-placement') || 'bottom-start'
    const shouldFlip = this.refs.menuWrapper.getAttribute('data-flip') !== 'false'
    const offsetValue = this.refs.menuWrapper.getAttribute('data-offset')

    const middleware = []
    if (offsetValue && !isNaN(parseInt(offsetValue))) {
      middleware.push(offset(parseInt(offsetValue)))
    }
    if (shouldFlip) {
      middleware.push(flip())
    }

    computePosition(this.refs.referenceElement, this.refs.menuWrapper, {
      placement: placement,
      middleware: middleware
    }).then(({x, y}) => {
      Object.assign(this.refs.menuWrapper.style, {
        top: `${y}px`,
        left: `${x}px`
      })
    }).catch(error => {
      console.error('[Prima Dropdown] Failed to position menu:', error)
    })
  }
}
