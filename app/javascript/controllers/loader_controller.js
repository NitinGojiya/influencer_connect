import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["frame", "loader"]

  connect() {
    // console.log("Loader controller connected")
    if (this.hasFrameTarget) {   // check if frame exists
      this.frameTarget.addEventListener("turbo:before-fetch-request", this.show)
      this.frameTarget.addEventListener("turbo:frame-load", this.hide)
    }
  }

  disconnect() {
    if (this.hasFrameTarget) {   // only remove listeners if frame exists
      this.frameTarget.removeEventListener("turbo:before-fetch-request", this.show)
      this.frameTarget.removeEventListener("turbo:frame-load", this.hide)
    }
  }


  show = () => {
    // console.log("🚀 Loader shown")
    this.loaderTarget.classList.remove("hidden")
  }

  hide = () => {
    // console.log("✅ Loader hidden")
    this.loaderTarget.classList.add("hidden")
  }
}
