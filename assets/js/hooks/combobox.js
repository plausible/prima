export default {
  mounted() {
    this.el.addEventListener('mouseover', this.onHover.bind(this))
    this.el.addEventListener('keydown', this.onKey.bind(this))
    this.el.querySelector('input').addEventListener('focus', this.showOptions.bind(this))
    this.el.querySelector('input').addEventListener('blur', this.hideOptions.bind(this))

    if(document.activeElement === this.el.querySelector('input')) {
      this.showOptions()
    }
    this.el.querySelector('input').dispatchEvent(new Event("input", {bubbles: true}))
    // this.el.querySelector('input').addEventListener('input', this.onInput.bind(this))
  },

  beforeUpdate() {
    this.activeValueBeforeUpdate = this.el.querySelector('[role=option][data-focus=true]')?.getAttribute('data-value')
  },

  updated() {
    const activeDomNode = this.el.querySelector(`[role=option][data-value=${this.activeValueBeforeUpdate}]`)
    if (this.activeValueBeforeUpdate && activeDomNode) {
      this.setFocus(activeDomNode)
    } else {
      this.focusFirstOption()
    }
  },

  setFocus(el) {
    this.el.querySelector('[role=option][data-focus=true]')?.removeAttribute('data-focus')
    el.setAttribute('data-focus', 'true')
  },

  onKey(e) {
    const allOptions = Array.from(this.el.querySelectorAll('[role=option]'))
    const firstOption = allOptions[0]
    const lastOption = allOptions[allOptions.length - 1]
    const currentFocusIndex = allOptions.findIndex(option => option.getAttribute('data-focus') === 'true')

    if (e.key === 'ArrowUp') {
      if (firstOption.getAttribute('data-focus') === 'true') {
        this.setFocus(lastOption)
      } else {
        this.setFocus(allOptions[currentFocusIndex - 1])
      }
    } else if (e.key === 'ArrowDown') {
      if (lastOption.getAttribute('data-focus') === 'true') {
        this.setFocus(firstOption)
      } else {
        this.setFocus(allOptions[currentFocusIndex + 1])
      }
    }
  },

  onHover(e) {
    if (e.target.getAttribute('role') === 'option') {
      this.setFocus(e.target)
    }
  },

  onInput(e) {
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
  },

  hideOptions() {
    const options = this.el.querySelector('[data-livekit-ref=options]')
    this.liveSocket.execJS(options, options.getAttribute('js-hide'));
    this.el.querySelector('input').value = ''
    options.addEventListener('phx:hide-end', () => {
      for (const option of this.el.querySelectorAll('[role=option]')) {
        this.showOption(option) // reset the state
      }
    })
  },

  focusFirstOption() {
    const firstOption = this.el.querySelector('[role=option]:not([data-hidden])')
    firstOption && this.setFocus(firstOption)
  }
}
