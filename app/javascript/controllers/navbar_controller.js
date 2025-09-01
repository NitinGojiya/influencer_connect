// app/javascript/controllers/navbar_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["header", "text", "menu"] // ✅ added "menu" here

  connect() {
    this.toggleBackground = this.toggleBackground.bind(this)
    window.addEventListener("scroll", this.toggleBackground)
  }

  disconnect() {
    window.removeEventListener("scroll", this.toggleBackground)
  }

  // Scroll effect for header
  toggleBackground() {
    if (window.scrollY > 50) {
      this.headerTarget.classList.add("bg-blue-500", "shadow-md", "rounded-md", "text-white", "mt-2")
      this.textTarget.classList.add("text-white")
      this.headerTarget.classList.remove("bg-transparent")
    } else {
      this.headerTarget.classList.remove("bg-blue-500", "shadow-md", "rounded-md", "text-white")
      this.textTarget.classList.remove("text-white")
      this.headerTarget.classList.add("bg-transparent")
    }
  }

  // Mobile menu toggle
  toggle() {
    if (this.hasMenuTarget) {
      this.menuTarget.classList.toggle("hidden") // ✅ toggles mobile menu visibility
    }
  }
}
