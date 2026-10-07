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
    this.setupEventListeners()
    this.js().setAttribute(this.el, 'data-prima-ready', 'true')
  },

  updated() {
    this.initialize()
    this.setFocus(this.el.querySelector(SELECTORS.FOCUSED_OPTION))
  },

  reconnected() {
    this.initialize()
  },

  destroyed() {
    this.cleanup()
    this.popover?.destroy()
  },

  initialize() {
    this.setupElements()
    this.setupPopover()
    this.syncDisabledState()
    this.syncSelectionFromInput()
  },

  setupElements() {
    const button = this.el.querySelector(SELECTORS.BUTTON)
    const value = this.el.querySelector(SELECTORS.VALUE)
    const valueInput = this.el.querySelector(SELECTORS.VALUE_INPUT)
    const optionsWrapper = this.el.querySelector(SELECTORS.OPTIONS_WRAPPER)
    const listbox = this.el.querySelector(SELECTORS.LISTBOX)

    this.setupAriaRelationships(button, listbox)
    this.refs = { button, value, valueInput, optionsWrapper, listbox }
  },

  setupAriaRelationships(button, listbox) {
    this.js().setAttribute(button, 'aria-controls', listbox.id)
    this.js().setAttribute(listbox, 'aria-labelledby', button.id)
  },

  syncSelectionFromInput() {
    const option = this.findOptionByValue(this.refs.valueInput.value)
    this.syncSelectedState(option)
  },

  syncDisabledState() {
    const disabled = this.el.getAttribute('data-disabled') === 'true'
    this.refs.button.disabled = disabled
    if (disabled) this.popover.close()
  },

  setupPopover() {
    this.popover ||= new PopoverController(this, {
      initialFocus: () => this.refs.listbox,
      onClose: () => this.clearFocus()
    })
    this.popover.update({
      trigger: this.refs.button,
      wrapper: this.refs.optionsWrapper,
      panel: this.refs.listbox
    })
  },

  setupEventListeners() {
    this.listeners = [
      [this.el, 'click', event => {
        if (this.refs.button.contains(event.target)) this.popover.toggle()
        else if (this.refs.listbox.contains(event.target)) this.handleListboxClick(event)
      }],
      [this.el, 'mouseover', event => {
        if (this.refs.listbox.contains(event.target)) this.handleMouseOver(event)
      }],
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
    if (this.refs.button.disabled) return

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

    if (!this.popover.isOpen && document.activeElement === this.refs.button) {
      this.showListboxAndFocus(this.getFirstEnabledOption())
      return
    }

    const options = this.getEnabledOptions()
    if (options.length === 0) return

    const currentIndex = this.getCurrentFocusIndex(options)
    const targetIndex = currentIndex === options.length - 1 ? 0 : currentIndex + 1
    this.setFocus(options[targetIndex])
  },

  handleEnterOrSpace(e) {
    const focusedOption = this.popover.isOpen ? this.el.querySelector(SELECTORS.FOCUSED_OPTION) : null

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
    if (this.popover.isOpen) {
      e.preventDefault()
      const options = this.getEnabledOptions()
      if (options.length > 0) {
        this.setFocus(options[0])
      }
    }
  },

  handleEnd(e) {
    if (this.popover.isOpen) {
      e.preventDefault()
      const options = this.getEnabledOptions()
      if (options.length > 0) {
        this.setFocus(options[options.length - 1])
      }
    }
  },

  handleTypeahead(e) {
    if (!this.popover.isOpen || e.key.length !== 1 || !/[a-zA-Z0-9]/.test(e.key)) return

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

  handleMouseOver(e) {
    if (!this.popover.isOpen) return
    const option = e.target.closest(SELECTORS.OPTION)
    if (option && option.getAttribute('aria-disabled') !== 'true') {
      this.setFocus(option)
    }
  },

  handleListboxClick(e) {
    if (this.refs.button.disabled || !this.popover.isOpen) return

    const option = e.target.closest(SELECTORS.OPTION)
    if (option && option.getAttribute('aria-disabled') !== 'true') {
      this.selectOption(option)
      this.popover.close('selection')
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

  // Sync selection markers without changing the caller-rendered displayed value.
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
    return Array.from(this.el.querySelectorAll(SELECTORS.OPTION)).find(option => option.getAttribute('data-value') === value)
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

  getCurrentFocusIndex(options) {
    return Array.prototype.findIndex.call(options, option => option.hasAttribute('data-focus'))
  },

  setFocus(el) {
    this.clearFocus()
    if (el && el.getAttribute('aria-disabled') !== 'true') {
      this.js().setAttribute(el, 'data-focus', '')
      this.js().setAttribute(this.refs.listbox, 'aria-activedescendant', el.id)
    }
  },

  clearFocus() {
    const focused = this.el.querySelector(SELECTORS.FOCUSED_OPTION)
    if (focused) this.js().removeAttribute(focused, 'data-focus')
    this.js().removeAttribute(this.refs.listbox, 'aria-activedescendant')
  },

  showListboxAndFocus(optionToFocus) {
    this.popover.open()
    if (this.popover.isOpen && optionToFocus) this.setFocus(optionToFocus)
  }
}
