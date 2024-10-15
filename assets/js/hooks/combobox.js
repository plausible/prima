export default {
  mounted() {
    this.el.addEventListener('mouseover', this.onHover.bind(this))
    this.el.addEventListener('keydown', this.onKey.bind(this))
    this.el.querySelector('input').addEventListener('focus', this.showOptions.bind(this))
    this.el.querySelector('input').addEventListener('blur', this.hideOptions.bind(this))
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

  showOptions() {
    this.focusFirstOption()
    const options = this.el.querySelector('[data-livekit-ref=options]')
    this.liveSocket.execJS(options, options.getAttribute('js-show'));
  },

  hideOptions() {
    const options = this.el.querySelector('[data-livekit-ref=options]')
    this.liveSocket.execJS(options, options.getAttribute('js-hide'));
  },

  focusFirstOption() {
    const firstOption = this.el.querySelector('[role=option]')
    firstOption && this.setFocus(firstOption)
  },
}
