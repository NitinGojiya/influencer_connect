// app/javascript/controllers/message_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "preview"]

  connect() {
    this.inputTarget.addEventListener("change", this.showPreview.bind(this))
  }

  showPreview(event) {
    const file = event.target.files[0]

    if (file) {
      const reader = new FileReader()
      reader.onload = (e) => {
        this.previewTarget.src = e.target.result
        this.previewTarget.classList.remove("hidden")
      }
      reader.readAsDataURL(file)
    } else {
      this.clearPreview()
    }
  }

  clearPreview() {
    this.previewTarget.src = ""
    this.previewTarget.classList.add("hidden")
  }
}
