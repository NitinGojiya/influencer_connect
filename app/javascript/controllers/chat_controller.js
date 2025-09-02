// app/javascript/controllers/chat_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.markActiveChat()
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
}
