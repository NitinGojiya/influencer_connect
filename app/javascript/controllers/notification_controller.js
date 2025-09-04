import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log("Notification controller connected")
    console.log("Notification.permission =", Notification.permission)

    if (Notification.permission === "default") {
      Notification.requestPermission().then(permission => {
        console.log("Notification permission granted:", permission)
      })
    }

    // Add listener only once per page load
    if (!window.notificationListenerAdded) {
      document.addEventListener("turbo:before-stream-render", this.show.bind(this))
      window.notificationListenerAdded = true
      console.log("Notification listener added")
    }
  }
show(event) {
  const template = event.target.querySelector("template")
  if (!template) return

  const content = template.content.firstElementChild
  if (!content) return

  // Only trigger for messages
  if (content.dataset.notification !== "message") return

  const title = content.dataset.notificationTitle || "New message"
  const body  = content.dataset.notificationBody || ""
  const url   = content.dataset.notificationUrl || "/"

  console.log("Message notification data:", { title, body, url })

  if (Notification.permission === "granted") {
    const n = new Notification(title, { body })
    n.onclick = () => window.open(url, "_blank")
  }
}
}
