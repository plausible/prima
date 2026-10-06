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
  SUBMIT_INPUT: 'select[data-prima-ref=submit_input]',
  OPTIONS_WRAPPER: '[data-prima-ref="options-wrapper"]',
  OPTIONS: '[data-prima-ref="options"]',
  OPTION: '[role=option]',
  CREATE_OPTION: '[data-prima-ref=create-option]',
  SELECTIONS: '[data-prima-ref=selections]',
  SELECTION_TEMPLATE: '[data-prima-ref=selection-template]',
  SELECTION_ITEM: '[data-prima-ref="selection-item"]',
  SELECTION_LABEL: '[data-prima-ref="selection-label"]',
  REMOVE_SELECTION: '[data-prima-ref="remove-selection"]',
  VISIBLE_OPTION: '[role=option]:not([data-hidden])',
  FOCUSED_OPTION: '[role=option][data-focus=true]',
  REGULAR_OPTION: '[role=option]:not([data-prima-ref=create-option])'
}

export default {
  mounted() {
    this.isOpen = false
    this.setupElements()
    this.setupEventListeners()
    this.syncSelectedAttributes()
    this.setupAriaAttributes()
    this.syncSelection()
    this.close()
    this.sendQuery('')
    this.js().setAttribute(this.el, 'data-prima-ready', 'true')
  },

  reconnected() {
    this.handleBlur()
    this.lastSentQuery = undefined
    this.sendQuery('')
  },

  disconnected() {
    clearTimeout(this.searchTimer)
  },

  destroyed() {
    this.cleanup()
  },

  setupElements() {
    this.refs = {
      searchInput: this.el.querySelector(SELECTORS.SEARCH_INPUT),
      submitInput: this.el.querySelector(SELECTORS.SUBMIT_INPUT),
      optionsWrapper: this.el.querySelector(SELECTORS.OPTIONS_WRAPPER),
      optionsContainer: this.el.querySelector(SELECTORS.OPTIONS),
      selectionsContainer: this.el.querySelector(SELECTORS.SELECTIONS)
    }

    this.refs.createOption = this.refs.optionsContainer?.querySelector(SELECTORS.CREATE_OPTION)
    this.refs.selectionTemplate = this.refs.selectionsContainer?.querySelector(SELECTORS.SELECTION_TEMPLATE)

    const referenceSelector = this.refs.optionsWrapper?.getAttribute('data-reference')
    this.refs.referenceElement = referenceSelector ? document.querySelector(referenceSelector) : this.refs.searchInput

    this.isMultiple = this.el.hasAttribute('data-multiple')
    if (this.refs.submitInput) this.refs.submitInput.multiple = this.isMultiple
  },

  setupEventListeners() {
    const onSearchInput = handler => event => {
      if (event.target === this.refs.searchInput) handler(event)
    }

    this.listeners = [
      [this.el, 'keydown', this.handleKeydown.bind(this)],
      [this.el, 'click', this.handleClick.bind(this)],
      [document, 'click', this.handleClickOutside.bind(this)],
      [this.el, 'focusin', onSearchInput(this.handleSearchFocus.bind(this))],
      [this.el, 'click', onSearchInput(this.handleSearchClick.bind(this))],
      [this.el, 'change', onSearchInput(e => e.stopPropagation())],
      [this.el, 'input', onSearchInput(this.handleInput.bind(this))]
    ]

    if (this.refs.optionsContainer) {
      this.listeners.push(
        [this.refs.optionsContainer, 'mouseover', this.handleHover.bind(this)],
        [this.refs.optionsContainer, 'phx:show-start', this.startPositioning.bind(this)],
        [this.refs.optionsContainer, 'phx:show-end', this.handleShowEnd.bind(this)],
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
        this.js().setAttribute(this.refs.searchInput, 'aria-controls', optionsId)
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
    clearTimeout(this.searchTimer)
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
    this.setupElements()
    this.syncSelection(document.activeElement === this.refs.searchInput)
    this.setupAriaAttributes()
    this.positionOptions()
    if (this.isOpen) this.restoreOptionFocus()
    this.syncSelectedAttributes()
    this.js().setAttribute(this.el, 'data-prima-ready', 'true')
  },

  restoreOptionFocus() {
    const options = this.getVisibleOptions()
    const focused = this.getCurrentFocusedOption()
    if (options.includes(focused)) {
      this.js().setAttribute(this.refs.searchInput, 'aria-activedescendant', focused.id)
      return
    }

    const focusedOption = options.find(option => option.dataset.value === this.focusedOptionBeforeUpdate) || options[0]
    if (focusedOption) {
      this.setFocus(focusedOption)
    } else {
      this.js().removeAttribute(this.refs.searchInput, 'aria-activedescendant')
    }
  },

  sendQuery(query) {
    clearTimeout(this.searchTimer)
    const input = this.refs.searchInput
    const event = input.dataset.onSearch
    if (!event) return
    if (query === this.lastSentQuery) return

    const target = input.getAttribute('phx-target')
    const request = target
      ? this.pushEventTo(target, event, { query })
      : this.pushEvent(event, { query })
    this.lastSentQuery = query
    request.catch(error => console.error('[Prima Combobox] Search failed:', error))
  },

  getVisibleOptions() {
    return Array.from(this.refs.optionsContainer?.querySelectorAll(SELECTORS.VISIBLE_OPTION) || [])
  },

  getRegularOptions() {
    return this.refs.optionsContainer?.querySelectorAll(SELECTORS.REGULAR_OPTION) || []
  },

  getSelectedValues() {
    return Array.from(this.refs.submitInput?.selectedOptions || []).map(option => option.value)
  },

  syncSelection(preserveSearch = false) {
    const input = this.refs.submitInput
    if (!input) return

    // Like a native text input, focused edits win; a later unfocused patch can
    // apply the latest server value, even when that value has not changed again.
    // Without a server binding, patches retain the current client selection.
    const selection = preserveSearch || !input.hasAttribute('data-selection')
      ? Array.from(input.options, option => [option.value, option.textContent])
      : JSON.parse(input.dataset.selection)
    const options = Array.from(this.getRegularOptions())
    input.replaceChildren()
    this.refs.selectionsContainer?.querySelectorAll(SELECTORS.SELECTION_ITEM).forEach(pill => pill.remove())

    for (const [value, display] of selection) {
      const option = options.find(option => option.dataset.value === value)
      const label = display ?? option?.dataset.display ?? value
      this.addSelection({ value, label })
    }

    if (!preserveSearch) {
      this.refs.searchInput.value = this.isMultiple ? '' : input.selectedOptions[0]?.textContent ?? ''
    }
  },

  addSelection(item) {
    if (!this.refs.submitInput) return false

    const { value } = item
    const selectedValues = this.getSelectedValues()

    if (selectedValues.includes(value)) return false

    if (!this.isMultiple) {
      this.refs.submitInput.replaceChildren()
    }

    // Keep selected labels and values independently of the current search results.
    this.refs.submitInput.add(new Option(item.label, value, true, true))

    if (this.isMultiple) {
      this.appendSelectionPill(item)
    }

    this.syncSelectedAttributes()
    return true
  },

  removeSelection(value) {
    const option = Array.from(this.refs.submitInput?.options || []).find(option => option.value === value)
    if (!option) return

    if (this.isMultiple) {
      const pills = this.refs.selectionsContainer?.querySelectorAll(SELECTORS.SELECTION_ITEM) || []
      for (const pill of pills) {
        if (pill.dataset.value === value) pill.remove()
      }
    }

    option.remove()
    this.syncSelectedAttributes()
    this.notifyFormChange()
  },

  setFocus(el) {
    const focused = this.getCurrentFocusedOption()
    if (focused) this.js().removeAttribute(focused, 'data-focus')
    this.js().setAttribute(el, 'data-focus', 'true')

    // Update aria-activedescendant to point to the focused option
    if (el.id) {
      this.js().setAttribute(this.refs.searchInput, 'aria-activedescendant', el.id)
    }

    el.scrollIntoView({ block: 'nearest', inline: 'nearest' })
  },

  focusFirstOption() {
    const firstOption = this.refs.optionsContainer?.querySelector(SELECTORS.VISIBLE_OPTION)
    if (firstOption) {
      this.setFocus(firstOption)
    } else {
      this.js().removeAttribute(this.refs.searchInput, 'aria-activedescendant')
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

    const changed = this.addSelection({ value, label: displayValue })

    if (this.isMultiple) {
      this.refs.searchInput.value = ''
      this.refs.searchInput.focus()
    } else {
      this.refs.searchInput.value = displayValue
    }

    this.close()
    if (changed) this.notifyFormChange()
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

  appendSelectionPill({ value, label }) {
    if (!this.refs.selectionsContainer || !this.refs.selectionTemplate) return

    const pill = this.refs.selectionTemplate.content.cloneNode(true)
    for (const item of pill.querySelectorAll(SELECTORS.SELECTION_ITEM)) {
      item.dataset.value = value
    }
    for (const labelElement of pill.querySelectorAll(SELECTORS.SELECTION_LABEL)) {
      labelElement.textContent = label
    }
    for (const button of pill.querySelectorAll(SELECTORS.REMOVE_SELECTION)) {
      button.setAttribute('data-value', value)
      if (!button.hasAttribute('aria-label')) {
        button.setAttribute('aria-label', `Remove ${label}`)
      }
    }

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
    if (arrowKeys.includes(e.key) && !this.isOpen) {
      e.preventDefault()
      this.openOptions()
      return
    }

    // Other navigation keys only work when options are visible
    if (otherNavigationKeys.includes(e.key) && !this.isOpen) {
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
    this.handleBlur()
  },

  handleEnterOrTab(e) {
    if (!this.isOpen) {
      return
    }

    const focusedOption = this.getCurrentFocusedOption()
    if (e.key === KEYS.TAB && !this.getVisibleOptions().includes(focusedOption)) {
      this.handleBlur()
      return
    }

    e.preventDefault()
    this.selectOption(focusedOption)
  },

  handleBackspace(e) {
    // Multi-select: if input is already empty, remove last selection
    if (this.isMultiple && this.refs.searchInput.value === '') {
      e.preventDefault()
      const values = this.getSelectedValues()
      if (values.length > 0) {
        this.removeSelection(values[values.length - 1])
      }
    }
    // Note: When backspace empties the input (typing -> empty), clearing is handled in handleInput
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
    if (this.isOpen) {
      this.handleBlur()
    } else {
      this.openOptions()
    }
  },

  handleInput(e) {
    e.stopPropagation()
    const searchValue = e.target.value

    // Clear selection when search input becomes empty
    if (!this.isMultiple && searchValue === '' && this.getSelectedValues().length > 0) {
      this.removeSelection(this.getSelectedValues()[0])
    }

    this.updateCreateOption(searchValue)

    if (searchValue.length > 0) {
      this.showOptions()
    }

    if (this.refs.searchInput.dataset.onSearch) {
      this.focusedOptionBeforeUpdate = this.getCurrentFocusedOption()?.dataset.value
      clearTimeout(this.searchTimer)
      this.searchTimer = setTimeout(() => this.sendQuery(searchValue), Number(this.refs.searchInput.dataset.searchDebounce))
    } else {
      this.filterOptions(searchValue)
    }
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

    this.updateCreateOptionVisibility(searchValue)

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

  openOptions() {
    this.showOptions()
    this.sendQuery('')
  },

  showOptions() {
    if (!this.refs.optionsContainer || this.isOpen) return

    this.isOpen = true
    this.js().setAttribute(this.refs.searchInput, 'aria-expanded', 'true')
    // Reset local filtering for a fresh opening.
    for (const option of this.getRegularOptions()) {
      this.showOption(option)
    }
    // Wrapper pattern: Show wrapper first (display:block) so Floating UI can measure it,
    // then position it, then trigger inner options transition. This prevents the options from
    // briefly appearing at wrong position before jumping to correct position.
    this.refs.optionsWrapper.style.display = 'block'
    this.positionOptions()
    this.liveSocket.execJS(this.refs.optionsContainer, this.refs.optionsContainer.getAttribute('js-show'))
  },

  startPositioning() {
    // Setup autoUpdate to reposition on scroll/resize
    this.cleanupAutoUpdate()
    this.autoUpdateCleanup = autoUpdate(this.refs.referenceElement, this.refs.optionsWrapper, () => {
      this.positionOptions()
    })
  },

  handleShowEnd() {
    if (this.isOpen) this.focusFirstOption()
  },

  handleHideEnd() {
    this.refs.optionsWrapper.style.display = 'none'
    this.cleanupAutoUpdate()
  },

  close() {
    clearTimeout(this.searchTimer)
    this.js().removeAttribute(this.refs.searchInput, 'aria-activedescendant')
    if (this.refs.createOption) {
      this.hideOption(this.refs.createOption)
      this.refs.createOption.textContent = ''
      this.js().removeAttribute(this.refs.createOption, 'data-focus')
    }

    if (!this.refs.optionsContainer || !this.isOpen) return

    this.isOpen = false
    this.js().setAttribute(this.refs.searchInput, 'aria-expanded', 'false')
    this.liveSocket.execJS(this.refs.optionsContainer, this.refs.optionsContainer.getAttribute('js-hide'))
  },

  handleClickOutside(event) {
    if (this.isOpen && !this.refs.optionsContainer.contains(event.target) && !this.refs.searchInput.contains(event.target)) {
      this.handleBlur()
    }
  },

  handleBlur() {
    if (!this.isOpen) return

    this.refs.searchInput.value = this.isMultiple
      ? ''
      : this.refs.submitInput?.selectedOptions[0]?.textContent ?? ''

    this.close()
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

  notifyFormChange() {
    const input = this.refs.submitInput
    input.dispatchEvent(new Event('input', { bubbles: true }))
    input.dispatchEvent(new Event('change', { bubbles: true }))
  }
}
