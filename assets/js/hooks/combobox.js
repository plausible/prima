export default {
  mounted() {
    this.mode = this.getMode()
    this.createOption = this.el.querySelector('[data-prima-ref=create-option]')
    this.hasCreateOption = !!this.createOption
    this.el.addEventListener('mouseover', this.onHover.bind(this))
    this.el.addEventListener('keydown', this.onKey.bind(this))
    this.el.addEventListener('click', this.onClick.bind(this))
    this.el.querySelector('input[data-prima-ref=search_input]').addEventListener('focus', this.showOptions.bind(this))

    this.initializeCreateOption()

    if(document.activeElement === this.el.querySelector('input[data-prima-ref=search_input]')) {
      this.showOptions()
    }
    this.el.querySelector('input[data-prima-ref=search_input]').dispatchEvent(new Event("input", {bubbles: true}))
    this.el.querySelector('input').addEventListener('input', this.onInput.bind(this))
  },

  updated() {
    const focusedDomNode = this.el.querySelector(`[role=option][data-value="${this.focusedOptionBeforeUpdate}"]`)
    if (this.focusedOptionBeforeUpdate && focusedDomNode) {
      this.setFocus(focusedDomNode)
    } else {
      this.focusFirstOption()
    }
  },

  setFocus(el) {
    this.el.querySelector('[role=option][data-focus=true]')?.removeAttribute('data-focus')
    el.setAttribute('data-focus', 'true')
  },

  selectOption(el) {
    const value = el.getAttribute('data-value')
    const searchInput = this.el.querySelector('input[data-prima-ref=search_input]')
    const submitInput = this.el.querySelector('input[data-prima-ref=submit_input]')

    if (value === '__CREATE__') {
      const searchValue = searchInput.value
      submitInput.value = searchValue
      searchInput.value = searchValue
    } else {
      submitInput.value = value
      searchInput.value = value
    }

    this.hideOptions()
  },

  onClick(e) {
    if (e.target.getAttribute('role') === 'option') {
      this.selectOption(e.target)
    }
  },

  onKey(e) {
    const visibleOptions = Array.from(this.el.querySelectorAll('[role=option]:not([data-hidden])'))
    const firstOption = visibleOptions[0]
    const lastOption = visibleOptions[visibleOptions.length - 1]
    const currentFocusIndex = visibleOptions.findIndex(option => option.getAttribute('data-focus') === 'true')


    if (e.key === 'ArrowUp') {
      e.preventDefault()
      if (firstOption.getAttribute('data-focus') === 'true') {
        this.setFocus(lastOption)
      } else {
        this.setFocus(visibleOptions[currentFocusIndex - 1])
      }
    } else if (e.key === 'ArrowDown') {
      e.preventDefault()
      if (lastOption.getAttribute('data-focus') === 'true') {
        this.setFocus(firstOption)
      } else {
        this.setFocus(visibleOptions[currentFocusIndex + 1])
      }
    } else if (e.key === "Enter" || e.key === "Tab") {
      e.preventDefault()
      this.selectOption(this.currentlyFocusedOption())
      this.hideOptions()
    }
  },

  onHover(e) {
    if (e.target.getAttribute('role') === 'option') {
      this.setFocus(e.target)
    }
  },

  getMode() {
    const searchInput = this.el.querySelector('input[data-prima-ref=search_input]')
    const hasPhxChange = searchInput.hasAttribute('phx-change')

    return hasPhxChange ? 'async' : 'frontend'
  },

  onInput(e) {
    const searchValue = e.target.value

    // Update create option content and visibility
    if (this.hasCreateOption) {
      this.updateCreateOption(searchValue)
      this.updateCreateOptionVisibility(searchValue)
    }

    if (this.mode === 'async') {
      const options = this.el.querySelector('[data-prima-ref=options]')
      this.liveSocket.execJS(options, options.getAttribute('js-show'));
      this.focusedOptionBeforeUpdate = this.currentlyFocusedOption()?.dataset.value
    } else {
      const q = searchValue.toLowerCase()
      const allOptions = this.el.querySelectorAll('[role=option]:not([data-prima-ref=create-option])')
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

      if (previouslyFocusedOptionIsHidden) {
        this.focusFirstOption()
      }
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

  showOptions() {
    const options = this.el.querySelector('[data-prima-ref=options]')
    this.liveSocket.execJS(options, options.getAttribute('js-show'));
    this.el.querySelector('input[data-prima-ref=search_input]').select()

    // Update create option when showing options
    if (this.hasCreateOption) {
      const searchValue = this.el.querySelector('input[data-prima-ref=search_input]').value
      this.updateCreateOption(searchValue)
      this.updateCreateOptionVisibility(searchValue)
    }

    this.focusFirstOption()

    const handleClickOutside = (event) => {
      if (!options.contains(event.target) && !this.el.querySelector('input[data-prima-ref=search_input]').contains(event.target)) {
        this.resetOnBlur()
        document.removeEventListener('click', handleClickOutside)
      }
    }

    document.addEventListener('click', handleClickOutside)
  },

  resetOnBlur() {
    const searchInput = this.el.querySelector('input[data-prima-ref=search_input]')
    const submitInput = this.el.querySelector('input[data-prima-ref=submit_input]')

    if (submitInput.value.length > 0 && searchInput.value.length > 0) {
      searchInput.value = submitInput.value
    } else if (searchInput.value.length > 0) {
      searchInput.value = ''
      searchInput.dispatchEvent(new Event("input", {bubbles: true}))
      submitInput.value = ''
    }

    this.hideOptions()
  },

  hideOptions() {
    const options = this.el.querySelector('[data-prima-ref=options]')
    this.liveSocket.execJS(options, options.getAttribute('js-hide'));
    options.addEventListener('phx:hide-end', () => {
      for (const option of this.el.querySelectorAll('[role=option]')) {
        this.showOption(option) // reset the state
      }
    })
  },

  focusFirstOption() {
    const firstOption = this.el.querySelector('[role=option]:not([data-hidden])')
    firstOption && this.setFocus(firstOption)
  },

  currentlyFocusedOption() {
    return this.el.querySelector('[role=option][data-focus=true]')
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
    const regularOptions = this.el.querySelectorAll('[role=option]:not([data-prima-ref=create-option])')
    const hasStaticMatch = Array.from(regularOptions).some(option =>
      option.getAttribute('data-value') === searchValue
    )

    // Also check if search value matches current selected value (submit input)
    const submitInput = this.el.querySelector('input[data-prima-ref=submit_input]')
    const hasSelectedMatch = submitInput.value === searchValue


    return hasStaticMatch || hasSelectedMatch
  },

  initializeCreateOption() {
    if (!this.hasCreateOption) return

    // Hide create option initially since search input starts empty
    this.hideOption(this.createOption)
  }
}
