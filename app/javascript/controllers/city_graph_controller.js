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

    // If chart already exists, update it instead of creating a new one
    if (this.chart) {
      this.updateChart()
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

  // Optional: method to update chart data dynamically
  updateChart() {
    if (!this.chart) return
    this.chart.data.labels = this.labelsValue
    this.chart.data.datasets[0].data = this.dataValue
    this.chart.data.datasets[0].backgroundColor = this.colorsValue
    this.chart.update()
  }

  disconnect() {
    if (this.chart) {
      this.chart.destroy()
      this.chart = null
    }
  }
}
