import { computePosition, flip, offset, autoUpdate } from '@floating-ui/dom';

const KEYS = {
  ARROW_UP: 'ArrowUp',
  ARROW_DOWN: 'ArrowDown',
  ESCAPE: 'Escape',
  ENTER: 'Enter',
  TAB: 'Tab',
  BACKSPACE: 'Backspace',
  HOME: 'Home',
  END: 'End',
  PAGE_UP: 'PageUp',
  PAGE_DOWN: 'PageDown'
}

const SELECTORS = {
  SEARCH_INPUT: 'input[data-prima-ref=search_input]',
  SUBMIT_CONTAINER: '[data-prima-ref=submit_container]',
  OPTIONS_WRAPPER: '[data-prima-ref="options-wrapper"]',
  OPTIONS: '[data-prima-ref="options"]',
  OPTION: '[role=option]',
  CREATE_OPTION: '[data-prima-ref=create-option]',
  SELECTIONS: '[data-prima-ref=selections]',
  SELECTION_TEMPLATE: '[data-prima-ref=selection-template]',
  SELECTION_ITEM: '[data-prima-ref="selection-item"]',
  REMOVE_SELECTION: '[data-prima-ref="remove-selection"]',
  VISIBLE_OPTION: '[role=option]:not([data-hidden])',
  FOCUSED_OPTION: '[role=option][data-focus=true]',
  REGULAR_OPTION: '[role=option]:not([data-prima-ref=create-option])'
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
    this.initializeCreateOption()
    this.syncSelectedAttributes()
    this.setupAriaAttributes()

    if (this.mode === 'async') {
      this.refs.searchInput.dispatchEvent(new Event("input", {bubbles: true}))
    }

    this.el.setAttribute('data-prima-ready', 'true')
  },

  setupElements() {
    this.refs = {
      searchInput: this.el.querySelector(SELECTORS.SEARCH_INPUT),
      submitContainer: this.el.querySelector(SELECTORS.SUBMIT_CONTAINER),
      optionsWrapper: this.el.querySelector(SELECTORS.OPTIONS_WRAPPER),
      optionsContainer: this.el.querySelector(SELECTORS.OPTIONS),
      selectionsContainer: this.el.querySelector(SELECTORS.SELECTIONS)
    }

    this.refs.createOption = this.refs.optionsContainer?.querySelector(SELECTORS.CREATE_OPTION)
    this.refs.selectionTemplate = this.refs.selectionsContainer?.querySelector(SELECTORS.SELECTION_TEMPLATE)

    const referenceSelector = this.refs.optionsWrapper?.getAttribute('data-reference')
    this.refs.referenceElement = referenceSelector ? document.querySelector(referenceSelector) : this.refs.searchInput

    this.mode = this.getMode()
    this.isMultiple = this.el.hasAttribute('data-multiple')
    this.hasCreateOption = !!this.refs.createOption
  },

  setupEventListeners() {
    this.listeners = [
      [this.el, 'keydown', this.handleKeydown.bind(this)],
      [this.el, 'click', this.handleClick.bind(this)],
      [this.refs.searchInput, 'focus', this.handleSearchFocus.bind(this)],
      [this.refs.searchInput, 'click', this.handleSearchClick.bind(this)],
      [this.refs.searchInput, 'change', (e) => e.stopPropagation()],
      [this.refs.searchInput, 'input', this.handleInput.bind(this)]
    ]

    if (this.refs.optionsContainer) {
      this.listeners.push(
        [this.refs.optionsContainer, 'click', this.handleClick.bind(this)],
        [this.refs.optionsContainer, 'mouseover', this.handleHover.bind(this)],
        [this.refs.optionsContainer, 'phx:show-start', this.handleShowStart.bind(this)],
        [this.refs.optionsContainer, 'phx:hide-end', this.handleHideEnd.bind(this)]
      )
    }

    this.listeners.forEach(([element, event, handler]) => {
      if (element) {
        element.addEventListener(event, handler)
      }
    })
  },

  setupAriaAttributes() {
    // Set aria-controls to link the input to the options container
    if (this.refs.optionsContainer && this.refs.searchInput) {
      const optionsId = this.refs.optionsContainer.getAttribute('id')
      if (optionsId) {
        this.refs.searchInput.setAttribute('aria-controls', optionsId)
      }
    }

    // Generate unique IDs for each option if they don't have one
    this.ensureOptionIds()
  },

  ensureOptionIds() {
    if (!this.refs.optionsContainer) return

    const options = this.refs.optionsContainer.querySelectorAll(SELECTORS.OPTION)
    options.forEach((option, index) => {
      if (!option.id) {
        const comboboxId = this.el.id || 'combobox'
        option.id = `${comboboxId}-option-${index}`
      }
    })
  },

  cleanup() {
    this.cleanupAutoUpdate()

    if (this.listeners) {
      this.listeners.forEach(([element, event, handler]) => {
        if (element) {
          element.removeEventListener(event, handler)
        }
      })
      this.listeners = []
    }
  },

  updated() {
    this.ensureOptionIds()
    this.positionOptions()
    const focusedDomNode = this.refs.optionsContainer?.querySelector(`${SELECTORS.OPTION}[data-value="${this.focusedOptionBeforeUpdate}"]`)
    if (this.focusedOptionBeforeUpdate && focusedDomNode) {
      this.setFocus(focusedDomNode)
    } else {
      this.focusFirstOption()
    }
    this.syncSelectedAttributes()
  },

  getMode() {
    return this.refs.searchInput.hasAttribute('phx-change') ? 'async' : 'frontend'
  },

  getVisibleOptions() {
    return Array.from(this.refs.optionsContainer?.querySelectorAll(SELECTORS.VISIBLE_OPTION) || [])
  },

  getRegularOptions() {
    return this.refs.optionsContainer?.querySelectorAll(SELECTORS.REGULAR_OPTION) || []
  },

  isOptionsVisible() {
    if (!this.refs.optionsContainer) return false
    return this.refs.optionsContainer.style.display !== 'none'
  },

  getSelectedValues() {
    const inputs = this.refs.submitContainer?.querySelectorAll('input[type="hidden"]') || []
    return Array.from(inputs).map(input => input.value)
  },

  findOptionByValue(value) {
    if (!value) return null
    const allOptions = this.getRegularOptions()
    return Array.from(allOptions).find(option =>
      option.getAttribute('data-value') === value
    )
  },

  getSelectedOption() {
    const selectedValues = this.getSelectedValues()
    return this.findOptionByValue(selectedValues[0])
  },

  restoreSelectedDisplayValue() {
    const selectedOption = this.getSelectedOption()
    if (selectedOption) {
      this.refs.searchInput.value = selectedOption.getAttribute('data-display')
    } else {
      this.refs.searchInput.value = ''
    }
  },

  getInputName() {
    if (!this.refs.submitContainer) return ''
    const baseName = this.refs.submitContainer.getAttribute('data-input-name')
    return this.isMultiple ? baseName + '[]' : baseName
  },

  addSelection(value) {
    if (!this.refs.submitContainer) return

    const selectedValues = this.getSelectedValues()

    if (selectedValues.includes(value)) return

    if (!this.isMultiple) {
      this.refs.submitContainer.innerHTML = ''
    }

    const input = document.createElement('input')
    input.type = 'hidden'
    input.name = this.getInputName()
    input.value = value
    this.refs.submitContainer.appendChild(input)

    if (this.isMultiple) {
      this.appendSelectionPill(value)
    }

    this.syncSelectedAttributes()
    this.dispatchSelectionChange()
    this.notifyFormChange(input)
  },

  removeSelection(value) {
    const inputs = Array.from(this.refs.submitContainer.querySelectorAll('input[type="hidden"]'))
    const input = inputs.find(input => input.value === value)

    if (input) {
      this.notifyFormChange(input)
      input.remove()
    }

    if (this.isMultiple) {
      const pill = this.refs.selectionsContainer?.querySelector(
        `${SELECTORS.SELECTION_ITEM}[data-value="${value}"]`
      )
      pill?.remove()
    }

    this.syncSelectedAttributes()
    this.dispatchSelectionChange()
  },

  setFocus(el) {
    this.refs.optionsContainer?.querySelector(SELECTORS.FOCUSED_OPTION)?.removeAttribute('data-focus')
    el.setAttribute('data-focus', 'true')

    // Update aria-activedescendant to point to the focused option
    if (el.id) {
      this.refs.searchInput.setAttribute('aria-activedescendant', el.id)
    }

    el.scrollIntoView({ block: 'nearest', inline: 'nearest' })
  },

  focusFirstOption() {
    const firstOption = this.refs.optionsContainer?.querySelector(SELECTORS.VISIBLE_OPTION)
    if (firstOption) {
      this.setFocus(firstOption)
    }
  },

  getCurrentFocusedOption() {
    return this.refs.optionsContainer?.querySelector(SELECTORS.FOCUSED_OPTION)
  },

  navigateUp(e) {
    e.preventDefault()
    const visibleOptions = this.getVisibleOptions()
    if (visibleOptions.length === 0) return

    const currentFocusIndex = visibleOptions.findIndex(option => option.getAttribute('data-focus') === 'true')
    const targetIndex = currentFocusIndex <= 0 ? visibleOptions.length - 1 : currentFocusIndex - 1
    this.setFocus(visibleOptions[targetIndex])
  },

  navigateDown(e) {
    e.preventDefault()
    const visibleOptions = this.getVisibleOptions()
    if (visibleOptions.length === 0) return

    const currentFocusIndex = visibleOptions.findIndex(option => option.getAttribute('data-focus') === 'true')
    const targetIndex = currentFocusIndex === visibleOptions.length - 1 ? 0 : currentFocusIndex + 1
    this.setFocus(visibleOptions[targetIndex])
  },

  navigateToFirst(e) {
    e.preventDefault()
    const visibleOptions = this.getVisibleOptions()
    if (visibleOptions.length === 0) return
    this.setFocus(visibleOptions[0])
  },

  navigateToLast(e) {
    e.preventDefault()
    const visibleOptions = this.getVisibleOptions()
    if (visibleOptions.length === 0) return
    this.setFocus(visibleOptions[visibleOptions.length - 1])
  },

  selectOption(el) {
    if (!el) return

    let value = el.getAttribute('data-value')
    let displayValue = el.getAttribute('data-display')

    if (value === '__CREATE__') {
      value = this.refs.searchInput.value
      displayValue = value
    }

    this.addSelection(value)

    if (this.isMultiple) {
      this.refs.searchInput.value = ''
      this.refs.searchInput.focus()
    } else {
      this.refs.searchInput.value = displayValue
    }

    this.hideOptions()
  },

  syncSelectedAttributes() {
    if (!this.refs.optionsContainer) return

    const allOptions = this.getRegularOptions()
    const selectedValues = this.getSelectedValues()

    for (const option of allOptions) {
      const value = option.getAttribute('data-value')
      if (selectedValues.includes(value)) {
        option.setAttribute('data-selected', 'true')
      } else {
        option.removeAttribute('data-selected')
      }
    }
  },

  appendSelectionPill(value) {
    if (!this.refs.selectionsContainer || !this.refs.selectionTemplate) return

    const option = this.findOptionByValue(value)
    const displayValue = option ? option.getAttribute('data-display') : value

    const pill = this.refs.selectionTemplate.content.cloneNode(true)
    const item = pill.querySelector(SELECTORS.SELECTION_ITEM)
    item.dataset.value = value
    item.innerHTML = item.innerHTML.replaceAll('__VALUE__', displayValue)

    this.refs.selectionsContainer.appendChild(pill)
  },

  handleClick(e) {
    const removeButton = e.target.closest(SELECTORS.REMOVE_SELECTION)
    if (removeButton) {
      const value = removeButton.getAttribute('data-value')
      this.removeSelection(value)
      this.refs.searchInput.focus()
      return
    }

    const optionElement = e.target.closest(SELECTORS.OPTION)
    if (optionElement) {
      this.selectOption(optionElement)
    }
  },

  handleKeydown(e) {
    const arrowKeys = [KEYS.ARROW_UP, KEYS.ARROW_DOWN]
    const otherNavigationKeys = [KEYS.HOME, KEYS.END, KEYS.PAGE_UP, KEYS.PAGE_DOWN]

    // Arrow keys open options if closed, then navigate
    if (arrowKeys.includes(e.key) && !this.isOptionsVisible()) {
      e.preventDefault()
      this.showOptions()
      return
    }

    // Other navigation keys only work when options are visible
    if (otherNavigationKeys.includes(e.key) && !this.isOptionsVisible()) {
      return
    }

    const keyHandlers = {
      [KEYS.ARROW_UP]: () => this.navigateUp(e),
      [KEYS.ARROW_DOWN]: () => this.navigateDown(e),
      [KEYS.HOME]: () => this.navigateToFirst(e),
      [KEYS.PAGE_UP]: () => this.navigateToFirst(e),
      [KEYS.END]: () => this.navigateToLast(e),
      [KEYS.PAGE_DOWN]: () => this.navigateToLast(e),
      [KEYS.ESCAPE]: () => this.handleEscape(e),
      [KEYS.ENTER]: () => this.handleEnterOrTab(e),
      [KEYS.TAB]: () => this.handleEnterOrTab(e),
      [KEYS.BACKSPACE]: () => this.handleBackspace(e)
    }

    const handler = keyHandlers[e.key]
    if (handler) {
      handler()
    }
  },

  handleEscape(e) {
    e.preventDefault()

    if (!this.isMultiple) {
      this.restoreSelectedDisplayValue()
    } else {
      this.refs.searchInput.value = ''
    }

    this.hideOptions()
  },

  handleEnterOrTab(e) {
    if (!this.isOptionsVisible()) {
      return
    }
    e.preventDefault()
    this.selectOption(this.getCurrentFocusedOption())
  },

  handleBackspace(e) {
    if (this.isMultiple && this.refs.searchInput.value === '') {
      e.preventDefault()
      const values = this.getSelectedValues()
      if (values.length > 0) {
        this.removeSelection(values[values.length - 1])
      }
    }
  },

  handleHover(e) {
    const optionElement = e.target.closest(SELECTORS.OPTION)
    if (optionElement) {
      this.setFocus(optionElement)
    }
  },

  handleSearchFocus() {
    this.refs.searchInput.select()
  },

  handleSearchClick() {
    if (this.isOptionsVisible()) {
      this.hideOptions()
    } else {
      this.showOptions()
    }
  },

  handleInput(e) {
    const searchValue = e.target.value

    if (this.hasCreateOption) {
      this.updateCreateOption(searchValue)
    }

    if (this.mode === 'async') {
      this.handleAsyncMode()
    } else {
      e.stopPropagation()
      this.handleFrontendMode(searchValue)
    }
  },

  handleAsyncMode() {
    if (this.refs.searchInput.value.length > 0) {
      this.showOptions()
    }
    this.focusedOptionBeforeUpdate = this.getCurrentFocusedOption()?.dataset.value
  },

  handleFrontendMode(searchValue) {
    if (searchValue.length > 0) {
      this.showOptions()
    }

    this.filterOptions(searchValue)
  },

  filterOptions(searchValue) {
    const q = searchValue.toLowerCase()
    const allOptions = this.getRegularOptions()
    let previouslyFocusedOptionIsHidden = false

    for (const option of allOptions) {
      const optionVal = option.getAttribute('data-display').toLowerCase()
      if (optionVal.includes(q)) {
        this.showOption(option)
      } else {
        this.hideOption(option)
        if (option.getAttribute('data-focus') === 'true') {
          previouslyFocusedOptionIsHidden = true
        }
      }
    }

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

  positionOptions() {
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

    computePosition(this.refs.referenceElement, this.refs.optionsWrapper, {
      placement: placement,
      middleware: middleware
    }).then(({x, y}) => {
      Object.assign(this.refs.optionsWrapper.style, {
        top: `${y}px`,
        left: `${x}px`
      })
    }).catch(error => {
      console.error('[Prima Combobox] Failed to position options:', error)
    })
  },

  cleanupAutoUpdate() {
    if (this.autoUpdateCleanup) {
      this.autoUpdateCleanup()
      this.autoUpdateCleanup = null
    }
  },

  showOptions() {
    // Wrapper pattern: Show wrapper first (display:block) so Floating UI can measure it,
    // then position it, then trigger inner options transition. This prevents the options from
    // briefly appearing at wrong position before jumping to correct position.
    this.refs.optionsWrapper.style.display = 'block'
    this.positionOptions()
    this.liveSocket.execJS(this.refs.optionsContainer, this.refs.optionsContainer.getAttribute('js-show'));

    this.refs.optionsContainer.addEventListener('phx:show-end', () => {
      this.focusFirstOption()
    }, {once: true})

    this.setupClickOutsideHandler()
  },

  handleShowStart() {
    this.refs.searchInput.setAttribute('aria-expanded', 'true')

    // Setup autoUpdate to reposition on scroll/resize
    this.autoUpdateCleanup = autoUpdate(this.refs.referenceElement, this.refs.optionsWrapper, () => {
      this.positionOptions()
    })
  },

  handleHideEnd() {
    this.refs.optionsWrapper.style.display = 'none'
    this.cleanupAutoUpdate()
  },

  hideOptions() {
    if (!this.refs.optionsContainer) return

    this.liveSocket.execJS(this.refs.optionsContainer, this.refs.optionsContainer.getAttribute('js-hide'));
    this.refs.searchInput.setAttribute('aria-expanded', 'false')
    this.refs.searchInput.removeAttribute('aria-activedescendant')

    this.refs.optionsContainer.addEventListener('phx:hide-end', () => {
      const regularOptions = this.getRegularOptions()
      for (const option of regularOptions) {
        this.showOption(option)
      }
    }, { once: true })
  },

  setupClickOutsideHandler() {
    const handleClickOutside = (event) => {
      if (!this.refs.optionsContainer.contains(event.target) && !this.refs.searchInput.contains(event.target)) {
        this.handleBlur()
        document.removeEventListener('click', handleClickOutside)
      }
    }

    document.addEventListener('click', handleClickOutside)
  },

  handleBlur() {
    const hasSelection = this.getSelectedValues().length > 0
    const hasSearchText = this.refs.searchInput.value.length > 0

    if (hasSelection && hasSearchText) {
      this.restoreSelectedDisplayValue()
    } else if (hasSearchText) {
      this.refs.searchInput.value = ''
      this.refs.searchInput.dispatchEvent(new Event("input", {bubbles: true}))
      this.refs.submitContainer.innerHTML = ''
    }

    this.hideOptions()
  },

  initializeCreateOption() {
    if (!this.hasCreateOption) return
    this.hideOption(this.refs.createOption)
  },

  updateCreateOption(searchValue) {
    if (!this.refs.createOption) return
    this.refs.createOption.textContent = `Create "${searchValue}"`
  },

  updateCreateOptionVisibility(searchValue) {
    if (!this.refs.createOption) return

    if (searchValue.length > 0 && !this.hasExactMatch(searchValue)) {
      this.showOption(this.refs.createOption)
    } else {
      const createOptionHasFocus = this.refs.createOption.getAttribute('data-focus') === 'true'
      this.hideOption(this.refs.createOption)

      if (createOptionHasFocus) {
        this.focusFirstOption()
      }
    }
  },

  hasExactMatch(searchValue) {
    const regularOptions = this.getRegularOptions()
    const hasStaticMatch = Array.from(regularOptions).some(option =>
      option.getAttribute('data-value') === searchValue
    )

    const selectedValues = this.getSelectedValues()
    const hasSelectedMatch = selectedValues.includes(searchValue)

    return hasStaticMatch || hasSelectedMatch
  },

  notifyFormChange(input) {
    input.dispatchEvent(new Event('input', { bubbles: true }))
  },

  dispatchSelectionChange() {
    const phxChangeEvent = this.el.getAttribute('phx-change')
    if (!phxChangeEvent) return

    const inputName = this.refs.submitContainer.getAttribute('data-input-name')
    const selectedValues = this.getSelectedValues()

    const params = {
      [inputName]: this.isMultiple ? selectedValues : (selectedValues[0] || '')
    }

    const phxTarget = this.el.getAttribute('phx-target')

    if (phxTarget) {
      this.pushEventTo(phxTarget, phxChangeEvent, params)
    } else {
      this.pushEvent(phxChangeEvent, params)
    }
  }
}
