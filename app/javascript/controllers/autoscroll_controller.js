// app/javascript/controllers/autoscroll_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.scrollToBottom()
  }

  scrollToBottom() {
    this.element.scrollTop = this.element.scrollHeight
  }

  // This will trigger automatically when Turbo Streams append new messages
  mutate() {
    this.scrollToBottom()
  }
}
