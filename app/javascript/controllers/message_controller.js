import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "preview", "videoPreview", "submitButton"]

  connect() {
    this.inputTarget.addEventListener("change", this.showPreview.bind(this))

    this.form = this.element.querySelector("form")
    this.loader = document.getElementById("message_loader")

    if (this.form) {
      this.form.addEventListener("turbo:submit-start", (event) => {
        if (!this.hasContent()) {
          event.preventDefault() // Stop form submission
          // alert("Please add text or select an image/video before sending.")
          return
        }

        this.showLoader()
        this.disableButton()
        this.disableInput()
      })

      this.form.addEventListener("turbo:submit-end", () => {
        this.hideLoader()
        this.enableButton()
        this.enableInput()
        this.clearPreview()
        this.form.reset()
      })
    }
  }

  showPreview(event) {
    const file = event.target.files[0]

    if (file) {
      if (file.type.startsWith("image/")) {
        const reader = new FileReader()
        reader.onload = (e) => {
          this.previewTarget.src = e.target.result
          this.previewTarget.classList.remove("hidden")
          this.videoPreviewTarget.classList.add("hidden")
        }
        reader.readAsDataURL(file)
      } else if (file.type.startsWith("video/")) {
        this.previewTarget.classList.add("hidden")
        this.previewTarget.src = ""
        this.videoPreviewTarget.classList.remove("hidden")
      } else {
        this.clearPreview()
      }
    } else {
      this.clearPreview()
    }
  }

  hasContent() {
    // Check if text input has content OR a file is selected
    return (this.inputTarget.value.trim() !== "" || this.inputTarget.files.length > 0)
  }

  clearPreview() {
    this.inputTarget.value = ""
    this.previewTarget.src = ""
    this.previewTarget.classList.add("hidden")
    this.videoPreviewTarget.classList.add("hidden")
  }

  showLoader() {
    if (this.loader) this.loader.classList.remove("hidden")
  }

  hideLoader() {
    if (this.loader) this.loader.classList.add("hidden")
  }

  disableButton() {
    if (this.hasSubmitButtonTarget) {
      this.submitButtonTarget.disabled = true
      this.submitButtonTarget.classList.add("opacity-50", "cursor-not-allowed")
    }
  }

  enableButton() {
    if (this.hasSubmitButtonTarget) {
      this.submitButtonTarget.disabled = false
      this.submitButtonTarget.classList.remove("opacity-50", "cursor-not-allowed")
    }
  }

  disableInput() {
    if (this.hasInputTarget) {
      this.inputTarget.disabled = true
      this.inputTarget.classList.add("opacity-50", "cursor-not-allowed")
    }
  }

  enableInput() {
    if (this.hasInputTarget) {
      this.inputTarget.disabled = false
      this.inputTarget.classList.remove("opacity-50", "cursor-not-allowed")
    }
  }
}
