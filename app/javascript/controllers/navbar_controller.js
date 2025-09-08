// app/javascript/controllers/navbar_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["header", "text", "menu"]

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
      Object.assign(this.headerTarget.style, {
        backgroundColor: "hsl(var(--background))",
        color: "hsl(var(--foreground))",
        fontFamily: "system-ui, -apple-system, sans-serif",
        lineHeight: "1.6",
        transition: "var(--transition-premium)"
      })
      this.headerTarget.classList.add("shadow-md", "rounded-md", "mt-2")
      this.textTarget.classList.add("text-white")
    } else {
      this.headerTarget.style.backgroundColor = "transparent"
      this.headerTarget.style.color = "inherit"
      this.headerTarget.style.transition = "var(--transition-premium)"

      this.headerTarget.classList.remove("shadow-md", "rounded-md", "mt-2")
      this.textTarget.classList.remove("text-white")
    }
  }

  // Mobile menu toggle
  toggle() {
    if (this.hasMenuTarget) {
      this.menuTarget.classList.toggle("hidden")
    }
  }
}
