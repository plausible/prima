const MODE = 'async'

export default {
  mounted() {
    this.el.addEventListener('mouseover', this.onHover.bind(this))
    this.el.addEventListener('keydown', this.onKey.bind(this))
    this.el.addEventListener('click', this.onClick.bind(this))
    this.el.querySelector('input[data-livekit-ref=search_input]').addEventListener('focus', this.showOptions.bind(this))

    if(document.activeElement === this.el.querySelector('input[data-livekit-ref=search_input]')) {
      this.showOptions()
    }
    this.el.querySelector('input[data-livekit-ref=search_input]').dispatchEvent(new Event("input", {bubbles: true}))
    this.el.querySelector('input').addEventListener('input', this.onInput.bind(this))
  },

  beforeUpdate() {
    this.focusedOptionBeforeUpdate = this.currentlyFocusedOption()?.dataset.value
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
    this.el.querySelector('input[data-livekit-ref=submit_input]').value = value
    this.el.querySelector('input[data-livekit-ref=search_input]').value = value
    this.hideOptions()
  },

  onClick(e) {
    if (e.target.getAttribute('role') === 'option') {
      this.selectOption(e.target)
    }
  },

  onKey(e) {
    const allOptions = Array.from(this.el.querySelectorAll('[role=option]'))
    const firstOption = allOptions[0]
    const lastOption = allOptions[allOptions.length - 1]
    const currentFocusIndex = allOptions.findIndex(option => option.getAttribute('data-focus') === 'true')

    if (e.key === 'ArrowUp') {
      e.preventDefault()
      if (firstOption.getAttribute('data-focus') === 'true') {
        this.setFocus(lastOption)
      } else {
        this.setFocus(allOptions[currentFocusIndex - 1])
      }
    } else if (e.key === 'ArrowDown') {
      e.preventDefault()
      if (lastOption.getAttribute('data-focus') === 'true') {
        this.setFocus(firstOption)
      } else {
        this.setFocus(allOptions[currentFocusIndex + 1])
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

  onInput(e) {
    if (MODE === 'async') {
      const options = this.el.querySelector('[data-livekit-ref=options]')
      this.liveSocket.execJS(options, options.getAttribute('js-show'));
    } else {
      const q = e.target.value.toLowerCase()
      const allOptions = this.el.querySelectorAll('[role=option]')
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
    this.focusFirstOption()
    const options = this.el.querySelector('[data-livekit-ref=options]')
    this.liveSocket.execJS(options, options.getAttribute('js-show'));
    this.el.querySelector('input[data-livekit-ref=search_input]').select()

    // Add click outside listener
    const handleClickOutside = (event) => {
      if (!options.contains(event.target) && !this.el.querySelector('input[data-livekit-ref=search_input]').contains(event.target)) {
        this.resetOnBlur()
        document.removeEventListener('click', handleClickOutside)
      }
    }
    
    document.addEventListener('click', handleClickOutside)
  },

  resetOnBlur() {
    const searchInput = this.el.querySelector('input[data-livekit-ref=search_input]')
    const submitInput = this.el.querySelector('input[data-livekit-ref=submit_input]')

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
    const options = this.el.querySelector('[data-livekit-ref=options]')
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
  }
}
