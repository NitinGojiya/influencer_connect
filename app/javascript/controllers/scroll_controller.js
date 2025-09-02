// app/javascript/controllers/scroll_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  scrollUp() {
    window.scrollTo({ top: 0, behavior: "smooth" })
  }
}
