// app/javascript/controllers/city_graph_controller.js
// CDN build – no `import { Chart, … } from "chart.js"` required
// Chart.js registers itself on window.Chart when loaded via CDN

import { Controller } from "@hotwired/stimulus"

export default class CityGraphController extends Controller {
  static values = {
    labels: Array,
    data: Array,
    colors: Array
  }

  connect() {
    const canvas = this.element.querySelector("canvas")
    if (!canvas) {
      console.warn("CityGraphController: No <canvas> found in element")
      return
    }

    this.chart = new window.Chart(canvas.getContext("2d"), {
      type: "doughnut",
      data: {
        labels: this.labelsValue,
        datasets: [
          {
            label: "Traffic",
            data: this.dataValue,
            backgroundColor: this.colorsValue,
            borderWidth: 1
          }
        ]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        cutout: "70%",
        plugins: {
          legend: { display: false },
          tooltip: {
            callbacks: {
              label: (context) => `${context.label}: ${context.raw}`
            }
          }
        }
      }
    })
  }

  disconnect() {
    if (this.chart) {
      this.chart.destroy()
      this.chart = null
    }
  }
}