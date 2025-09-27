import { computePosition, flip, offset, autoUpdate } from '@floating-ui/dom';

export default {
  // === INITIALIZATION ===
  mounted() {
    this.initializeDOMCache()
    this.mode = this.getMode()
    this.hasCreateOption = !!this.createOption
    this.setupEventListeners()
    this.initializeCreateOption()
    if (this.mode === 'async') {
      this.searchInput.dispatchEvent(new Event("input", {bubbles: true}))
    }
  },

  initializeDOMCache() {
    this.searchInput = this.el.querySelector('input[data-prima-ref=search_input]')
    this.submitInput = this.el.querySelector('input[data-prima-ref=submit_input]')
    this.optionsContainer = this.getOptionsContainer()
    this.createOption = this.optionsContainer?.querySelector('[data-prima-ref=create-option]')
  },

  setupEventListeners() {
    this.el.addEventListener('keydown', this.onKey.bind(this))
    this.el.addEventListener('click', this.onClick.bind(this))
    this.optionsContainer?.addEventListener('click', this.onClick.bind(this))
    this.optionsContainer?.addEventListener('mouseover', this.onHover.bind(this))
    this.searchInput.addEventListener('focus', () => {
      this.searchInput.select()
      this.showOptions()
    })
    this.searchInput.addEventListener('input', this.onInput.bind(this))
  },

  updated() {
    this.positionOptions()
    const focusedDomNode = this.optionsContainer?.querySelector(`[role=option][data-value="${this.focusedOptionBeforeUpdate}"]`)
    if (this.focusedOptionBeforeUpdate && focusedDomNode) {
      this.setFocus(focusedDomNode)
    } else {
      this.focusFirstOption()
    }
  },

  destroyed() {
    this.cleanupAutoUpdate()
  },

  // === UTILITIES ===
  getOptionsContainer() {
    return this.el.querySelector('[data-prima-ref="options"]')
  },

  getMode() {
    const hasPhxChange = this.searchInput.hasAttribute('phx-change')
    return hasPhxChange ? 'async' : 'frontend'
  },

  getVisibleOptions() {
    return Array.from(this.optionsContainer?.querySelectorAll('[role=option]:not([data-hidden])') || [])
  },

  // === FOCUS MANAGEMENT ===
  setFocus(el) {
    this.optionsContainer?.querySelector('[role=option][data-focus=true]')?.removeAttribute('data-focus')
    el.setAttribute('data-focus', 'true')
  },

  focusFirstOption() {
    const firstOption = this.optionsContainer?.querySelector('[role=option]:not([data-hidden])')
    firstOption && this.setFocus(firstOption)
  },

  currentlyFocusedOption() {
    return this.optionsContainer?.querySelector('[role=option][data-focus=true]')
  },

  handleArrowNavigation(key, visibleOptions) {
    const firstOption = visibleOptions[0]
    const lastOption = visibleOptions[visibleOptions.length - 1]
    const currentFocusIndex = visibleOptions.findIndex(option => option.getAttribute('data-focus') === 'true')

    if (key === 'ArrowUp') {
      if (firstOption.getAttribute('data-focus') === 'true') {
        this.setFocus(lastOption)
      } else {
        this.setFocus(visibleOptions[currentFocusIndex - 1])
      }
    } else if (key === 'ArrowDown') {
      if (lastOption.getAttribute('data-focus') === 'true') {
        this.setFocus(firstOption)
      } else {
        this.setFocus(visibleOptions[currentFocusIndex + 1])
      }
    }
  },

  // === OPTION SELECTION ===
  selectOption(el) {
    const value = el.getAttribute('data-value')

    if (value === '__CREATE__') {
      const searchValue = this.searchInput.value
      this.submitInput.value = searchValue
      this.searchInput.value = searchValue
    } else {
      this.submitInput.value = value
      this.searchInput.value = value
    }

    this.hideOptions()
  },

  // === EVENT HANDLERS ===
  onClick(e) {
    // Use event delegation to find the closest option element
    const optionElement = e.target.closest('[role="option"]')
    if (optionElement) {
      this.selectOption(optionElement)
    }
  },

  onKey(e) {
    const visibleOptions = this.getVisibleOptions()

    if (e.key === 'ArrowUp' || e.key === 'ArrowDown') {
      e.preventDefault()
      this.handleArrowNavigation(e.key, visibleOptions)
    } else if (e.key === "Enter" || e.key === "Tab") {
      e.preventDefault()
      this.selectOption(this.currentlyFocusedOption())
      this.hideOptions()
    }
  },

  onHover(e) {
    // Use event delegation to find the closest option element
    const optionElement = e.target.closest('[role="option"]')
    if (optionElement) {
      this.setFocus(optionElement)
    }
  },

  onInput(e) {
    const searchValue = e.target.value

    // Update create option content first
    if (this.hasCreateOption) {
      this.updateCreateOption(searchValue)
    }

    if (this.mode === 'async') {
      this.handleAsyncMode()
    } else {
      this.handleFrontendMode(searchValue)
    }
  },

  handleAsyncMode() {
    // Only show options if there's actual content to search for
    if (this.searchInput.value.length > 0) {
      this.liveSocket.execJS(this.optionsContainer, this.optionsContainer.getAttribute('js-show'));
    }
    this.focusedOptionBeforeUpdate = this.currentlyFocusedOption()?.dataset.value
  },

  handleFrontendMode(searchValue) {
    if (searchValue.length > 0) {
      this.showOptions()
    }

    this.filterOptions(searchValue)
  },

  // === OPTION FILTERING & VISIBILITY ===
  filterOptions(searchValue) {
    const q = searchValue.toLowerCase()
    const allOptions = this.optionsContainer?.querySelectorAll('[role=option]:not([data-prima-ref=create-option])') || []
    let previouslyFocusedOptionIsHidden = false

    for (const option of allOptions) {
      const optionVal = option.getAttribute('data-value').toLowerCase()
      if (optionVal.includes(q)) {
        this.showOption(option)
      } else {
        this.hideOption(option)
        if (option.getAttribute('data-focus') === 'true') {
          previouslyFocusedOptionIsHidden = true
        }
      }
    }

    // Handle create option visibility after regular options are processed
    if (this.hasCreateOption) {
      this.updateCreateOptionVisibility(searchValue)
    }

    if (previouslyFocusedOptionIsHidden) {
      this.focusFirstOption()
    }
  },

  showOption(option) {
    option.style.display = 'block'
    option.removeAttribute('data-hidden')
  },

  hideOption(option) {
    option.style.display = 'none'
    option.setAttribute('data-hidden', 'true')
  },

  // === POSITIONING ===
  async positionOptions() {
    if (!this.optionsContainer) return

    const placement = this.optionsContainer.getAttribute('data-placement') || 'bottom-start'
    const shouldFlip = this.optionsContainer.getAttribute('data-flip') !== 'false'
    const offsetValue = this.optionsContainer.getAttribute('data-offset')

    const middleware = []
    if (offsetValue && !isNaN(parseInt(offsetValue))) {
      middleware.push(offset(parseInt(offsetValue)))
    }
    if (shouldFlip) {
      middleware.push(flip())
    }

    try {
      const {x, y} = await computePosition(this.searchInput, this.optionsContainer, {
        placement: placement,
        middleware: middleware
      })

      Object.assign(this.optionsContainer.style, {
        position: 'absolute',
        top: `${y}px`,
        left: `${x}px`
      })
    } catch (error) {
      console.error('Failed to position combobox options:', error)
    }
  },

  setupAutoUpdate() {
    if (!this.optionsContainer) return

    this.cleanup = autoUpdate(this.searchInput, this.optionsContainer, () => {
      this.positionOptions()
    })
  },

  cleanupAutoUpdate() {
    if (this.cleanup) {
      this.cleanup()
      this.cleanup = null
    }
  },

  // === OPTION LIFECYCLE ===
  showOptions() {
    this.liveSocket.execJS(this.optionsContainer, this.optionsContainer.getAttribute('js-show'));

    this.focusFirstOption()

    // Position options using floating-ui after element is fully rendered
    requestAnimationFrame(() => {
      this.positionOptions()
    })

    // Setup automatic repositioning with floating-ui's autoUpdate
    this.setupAutoUpdate()

    this.setupClickOutsideHandler()
  },

  setupClickOutsideHandler() {
    const handleClickOutside = (event) => {
      if (!this.optionsContainer.contains(event.target) && !this.searchInput.contains(event.target)) {
        this.resetOnBlur()
        document.removeEventListener('click', handleClickOutside)
        this.cleanupAutoUpdate()
      }
    }

    document.addEventListener('click', handleClickOutside)
  },

  resetOnBlur() {
    if (this.submitInput.value.length > 0 && this.searchInput.value.length > 0) {
      this.searchInput.value = this.submitInput.value
    } else if (this.searchInput.value.length > 0) {
      this.searchInput.value = ''
      this.searchInput.dispatchEvent(new Event("input", {bubbles: true}))
      this.submitInput.value = ''
    }

    this.hideOptions()
  },

  hideOptions() {
    if (!this.optionsContainer) return

    this.liveSocket.execJS(this.optionsContainer, this.optionsContainer.getAttribute('js-hide'));

    // Clean up autoUpdate when hiding
    this.cleanupAutoUpdate()

    this.optionsContainer.addEventListener('phx:hide-end', () => {
      for (const option of this.optionsContainer.querySelectorAll('[role=option]')) {
        this.showOption(option) // reset the state
      }
    })
  },

  // === CREATE OPTION MANAGEMENT ===
  initializeCreateOption() {
    if (!this.hasCreateOption) return

    // Hide create option initially since search input starts empty
    this.hideOption(this.createOption)
  },

  updateCreateOption(searchValue) {
    if (!this.createOption) return
    this.createOption.textContent = `Create "${searchValue}"`
  },

  updateCreateOptionVisibility(searchValue) {
    if (!this.createOption) return

    if (searchValue.length > 0 && !this.hasExactMatch(searchValue)) {
      this.showOption(this.createOption)
    } else {
      // Check if create option is currently focused before hiding it
      const createOptionHasFocus = this.createOption.getAttribute('data-focus') === 'true'
      this.hideOption(this.createOption)

      // If create option was focused, move focus to first visible option
      if (createOptionHasFocus) {
        this.focusFirstOption()
      }
    }
  },

  hasExactMatch(searchValue) {
    const regularOptions = this.optionsContainer?.querySelectorAll('[role=option]:not([data-prima-ref=create-option])') || []
    const hasStaticMatch = Array.from(regularOptions).some(option =>
      option.getAttribute('data-value') === searchValue
    )

    // Also check if search value matches current selected value (submit input)
    const hasSelectedMatch = this.submitInput.value === searchValue

    return hasStaticMatch || hasSelectedMatch
  }
}
