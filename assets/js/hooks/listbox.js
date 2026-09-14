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
  BUTTON: '[aria-haspopup="listbox"]',
  VALUE: '[data-prima-ref="value"]',
  VALUE_INPUT: '[data-prima-ref="value-input"]',
  OPTIONS_WRAPPER: '[data-prima-ref="options-wrapper"]',
  LISTBOX: '[role="listbox"]',
  OPTION: '[role="option"]',
  ENABLED_OPTION: '[role="option"]:not([aria-disabled="true"])',
  FOCUSED_OPTION: '[role="option"][data-focus]',
  SELECTED_OPTION: '[role="option"][aria-selected="true"]'
}

export default {
  mounted() {
    this.initialize()
    this.syncSelectionFromInput()
  },

  updated() {
    this.initialize()
    this.syncSelectionFromInput()
  },

  reconnected() {
    this.initialize()
    this.syncSelectionFromInput()
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
    const value = this.el.querySelector(SELECTORS.VALUE)
    const valueInput = this.el.querySelector(SELECTORS.VALUE_INPUT)
    const optionsWrapper = this.el.querySelector(SELECTORS.OPTIONS_WRAPPER)
    const listbox = this.el.querySelector(SELECTORS.LISTBOX)

    const referenceSelector = optionsWrapper?.getAttribute('data-reference')
    const referenceElement = referenceSelector ? document.querySelector(referenceSelector) : button

    this.setupAriaRelationships(button, listbox)
    this.refs = { button, value, valueInput, optionsWrapper, listbox, referenceElement }
  },

  setupAriaRelationships(button, listbox) {
    button.setAttribute('aria-controls', listbox.id)
    listbox.setAttribute('aria-labelledby', button.id)
  },

  syncSelectionFromInput() {
    const option = this.findOptionByValue(this.refs.valueInput.value)
    this.syncSelectedState(option)
  },

  setupEventListeners() {
    this.listeners = [
      [this.refs.button, 'click', this.handleToggle.bind(this)],
      [this.refs.listbox, 'mouseover', this.handleMouseOver.bind(this)],
      [this.refs.listbox, 'click', this.handleListboxClick.bind(this)],
      [this.el, 'keydown', this.handleKeydown.bind(this)],
      [this.el, 'prima:close', this.handleClose.bind(this)],
      [this.refs.listbox, 'phx:show-start', this.handleShowStart.bind(this)],
      [this.refs.listbox, 'phx:hide-end', this.handleHideEnd.bind(this)]
    ]

    this.listeners.forEach(([element, event, handler]) => {
      element.addEventListener(event, handler)
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

    if (!this.isListboxVisible() && document.activeElement === this.refs.button) {
      this.showListboxAndFocus(this.getLastEnabledOption())
      return
    }

    const options = this.getEnabledOptions()
    if (options.length === 0) return

    const currentIndex = this.getCurrentFocusIndex(options)
    const targetIndex = currentIndex === 0 ? options.length - 1 : currentIndex - 1
    this.setFocus(options[targetIndex])
  },

  navigateDown(e) {
    e.preventDefault()

    if (!this.isListboxVisible() && document.activeElement === this.refs.button) {
      this.showListboxAndFocus(this.getFirstEnabledOption())
      return
    }

    const options = this.getEnabledOptions()
    if (options.length === 0) return

    const currentIndex = this.getCurrentFocusIndex(options)
    const targetIndex = currentIndex === options.length - 1 ? 0 : currentIndex + 1
    this.setFocus(options[targetIndex])
  },

  handleEscape() {
    this.hideListbox()
    this.refs.button.focus()
  },

  handleEnterOrSpace(e) {
    // Only trust a focused option while the listbox is actually open - data-focus can
    // linger on an option after Escape closes the listbox, since clearing it happens in
    // the async phx:hide-end handler, not synchronously in hideListbox(). Without this
    // guard, a fast Escape followed by Enter/Space can "click" a stale focused option
    // instead of reopening the listbox.
    const focusedOption = this.isListboxVisible() ? this.el.querySelector(SELECTORS.FOCUSED_OPTION) : null

    if (focusedOption && focusedOption.getAttribute('aria-disabled') !== 'true') {
      // An option is focused - click it
      e.preventDefault()
      focusedOption.click()
    } else if (document.activeElement === this.refs.button) {
      // Button is focused - open listbox
      e.preventDefault()
      this.showListboxAndFocus(this.getSelectedOrFirstEnabledOption())
    }
  },

  handleHome(e) {
    if (this.isListboxVisible()) {
      e.preventDefault()
      const options = this.getEnabledOptions()
      if (options.length > 0) {
        this.setFocus(options[0])
      }
    }
  },

  handleEnd(e) {
    if (this.isListboxVisible()) {
      e.preventDefault()
      const options = this.getEnabledOptions()
      if (options.length > 0) {
        this.setFocus(options[options.length - 1])
      }
    }
  },

  handleTypeahead(e) {
    if (!this.isListboxVisible() || e.key.length !== 1 || !/[a-zA-Z0-9]/.test(e.key)) return

    e.preventDefault()

    const searchChar = e.key.toLowerCase()
    const options = this.getEnabledOptions()
    const matchingOptions = Array.from(options).filter(option =>
      option.textContent.trim().toLowerCase().startsWith(searchChar)
    )

    if (matchingOptions.length === 0) return

    const currentFocused = this.el.querySelector(SELECTORS.FOCUSED_OPTION)
    const currentIndex = currentFocused && matchingOptions.includes(currentFocused)
      ? matchingOptions.indexOf(currentFocused)
      : -1

    const nextIndex = currentIndex >= 0 && currentIndex < matchingOptions.length - 1
      ? currentIndex + 1
      : 0

    this.setFocus(matchingOptions[nextIndex])
  },

  handleClose() {
    this.hideListbox()
  },

  handleToggle() {
    this.toggleListbox()
  },

  handleMouseOver(e) {
    if (e.target.getAttribute('role') === 'option' &&
        e.target.getAttribute('aria-disabled') !== 'true') {
      this.setFocus(e.target)
    }
  },

  handleListboxClick(e) {
    const option = e.target.closest(SELECTORS.OPTION)
    if (option && option.getAttribute('aria-disabled') !== 'true') {
      this.selectOption(option)
      this.hideListbox()
      this.refs.button.focus()
    }
  },

  // User-driven selection: updates the form and displayed values
  // instantly, ahead of any server round-trip.
  selectOption(option) {
    const value = option.getAttribute('data-value')

    if (this.refs.valueInput.value !== value) {
      this.refs.valueInput.value = value
      this.refs.valueInput.dispatchEvent(new Event('input', { bubbles: true }))
    }

    this.syncSelectedState(option)
    this.refs.value.textContent = option.getAttribute('data-display')
  },

  // Mount-time sync only: the displayed value is rendered by the caller and is
  // already correct on first paint, so only the ARIA/visual selection markers
  // are synced here - the value itself is left untouched.
  syncSelectedState(option) {
    this.el.querySelector(SELECTORS.SELECTED_OPTION)?.removeAttribute('aria-selected')
    this.el.querySelectorAll('[data-selected]').forEach(el => el.removeAttribute('data-selected'))

    if (option) {
      option.setAttribute('aria-selected', 'true')
      option.setAttribute('data-selected', 'true')
    }
  },

  findOptionByValue(value) {
    if (!value) return null
    return Array.from(this.getAllOptions()).find(option => option.getAttribute('data-value') === value)
  },

  getAllOptions() {
    return this.el.querySelectorAll(SELECTORS.OPTION)
  },

  getEnabledOptions() {
    return this.el.querySelectorAll(SELECTORS.ENABLED_OPTION)
  },

  getFirstEnabledOption() {
    return this.getEnabledOptions()[0]
  },

  getLastEnabledOption() {
    const options = this.getEnabledOptions()
    return options[options.length - 1]
  },

  getSelectedOrFirstEnabledOption() {
    const selected = this.el.querySelector(SELECTORS.SELECTED_OPTION)
    if (selected && selected.getAttribute('aria-disabled') !== 'true') return selected
    return this.getFirstEnabledOption()
  },

  isListboxVisible() {
    const wrapper = this.refs.optionsWrapper
    return wrapper && wrapper.style.display !== 'none' && wrapper.offsetParent !== null
  },

  getCurrentFocusIndex(options) {
    return Array.prototype.findIndex.call(options, option => option.hasAttribute('data-focus'))
  },

  setFocus(el) {
    this.clearFocus()
    if (el && el.getAttribute('aria-disabled') !== 'true') {
      el.setAttribute('data-focus', '')
      this.refs.listbox.setAttribute('aria-activedescendant', el.id)
    } else {
      this.refs.listbox.removeAttribute('aria-activedescendant')
    }
  },

  clearFocus() {
    this.el.querySelector(SELECTORS.FOCUSED_OPTION)?.removeAttribute('data-focus')
  },

  hideListbox() {
    liveSocket.execJS(this.refs.listbox, this.refs.listbox.getAttribute('js-hide'))
    this.refs.optionsWrapper.style.display = 'none'
  },

  toggleListbox() {
    if (this.isListboxVisible()) {
      this.hideListbox()
    } else {
      this.showListboxAndFocus(null)
    }
  },

  showListboxAndFocus(optionToFocus) {
    // Wrapper pattern: Show wrapper first (display:block) so Floating UI can measure it,
    // then position it, then trigger inner listbox transition. This prevents the listbox
    // from briefly appearing at wrong position before jumping to correct position.
    this.refs.optionsWrapper.style.display = 'block'
    this.positionListbox()
    liveSocket.execJS(this.refs.listbox, this.refs.listbox.getAttribute('js-show'))

    if (optionToFocus) {
      this.setFocus(optionToFocus)
    }
  },

  // phx:show-start/phx:hide-end are dispatched asynchronously by LiveView's transition
  // machinery, and the actual display mutation on the inner listbox happens as part of
  // that same internal, multi-step async completion - not synchronously with these
  // events. A rapid close-then-reopen (or reopen-then-close) can call execJS(show) and
  // execJS(hide) back-to-back before the previous call's internal steps finish, so their
  // completions interleave and whichever happens to run last wins, regardless of which
  // was issued most recently. Both handlers defensively re-assert the inner listbox's
  // display against our own synchronous source of truth (the wrapper, which
  // showListboxAndFocus/hideListbox control directly) so a stale completion corrects
  // itself instead of leaving the inner element in the wrong state.
  handleShowStart() {
    const shouldBeOpen = this.isListboxVisible()
    this.refs.listbox.style.display = shouldBeOpen ? '' : 'none'
    if (!shouldBeOpen) return

    this.refs.button.setAttribute('aria-expanded', 'true')
    this.refs.listbox.focus({ preventScroll: true })

    // Setup autoUpdate to reposition on scroll/resize
    this.cleanupAutoUpdate()
    this.autoUpdateCleanup = autoUpdate(this.refs.referenceElement, this.refs.optionsWrapper, () => {
      this.positionListbox()
    })
  },

  handleHideEnd() {
    const shouldBeOpen = this.isListboxVisible()
    this.refs.listbox.style.display = shouldBeOpen ? '' : 'none'
    if (shouldBeOpen) return

    this.clearFocus()
    this.refs.listbox.removeAttribute('aria-activedescendant')
    this.refs.button.setAttribute('aria-expanded', 'false')
    this.refs.optionsWrapper.style.display = 'none'
    this.cleanupAutoUpdate()
  },

  positionListbox() {
    if (!this.refs.optionsWrapper) return

    const placement = this.refs.optionsWrapper.getAttribute('data-placement') || 'bottom-start'
    const shouldFlip = this.refs.optionsWrapper.getAttribute('data-flip') !== 'false'
    const offsetValue = this.refs.optionsWrapper.getAttribute('data-offset')

    const middleware = []
    if (offsetValue && !isNaN(parseInt(offsetValue))) {
      middleware.push(offset(parseInt(offsetValue)))
    }
    if (shouldFlip) {
      middleware.push(flip())
    }

    const matchTriggerWidth = this.refs.optionsWrapper.hasAttribute('data-match-trigger-width')
    this.refs.optionsWrapper.style.minWidth = matchTriggerWidth
      ? `${this.refs.referenceElement.offsetWidth}px`
      : ''

    computePosition(this.refs.referenceElement, this.refs.optionsWrapper, {
      placement: placement,
      middleware: middleware
    }).then(({x, y}) => {
      Object.assign(this.refs.optionsWrapper.style, {
        top: `${y}px`,
        left: `${x}px`
      })
    }).catch(error => {
      console.error('[Prima Listbox] Failed to position listbox:', error)
    })
  }
}
