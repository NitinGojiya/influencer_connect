// app/javascript/controllers/chat_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.markActiveChat()
    this.setupFormReset()
  }

  markActiveChat() {
    const links = this.element.querySelectorAll("a")
    links.forEach(link => {
      link.addEventListener("click", () => {
        links.forEach(l => l.classList.remove("bg-gray-200"))
        link.classList.add("bg-gray-200")
      })
    })
  }

  setupFormReset() {
    // Listen for Turbo form submissions ending on the whole document
    document.addEventListener("turbo:submit-end", (event) => {
      const form = event.target
      if (form.closest("#new_message_form")) {
        form.reset() // Clears input and file uploads
      }
    })
  }
}
