import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  connect () {
    setTimeout(() => {
      this.close()
    }, 3000)
  }

  close () {
    this.element.classList.add('fading')

    setTimeout(() => {
      this.element.remove()
    }, 1000)
  }
}
