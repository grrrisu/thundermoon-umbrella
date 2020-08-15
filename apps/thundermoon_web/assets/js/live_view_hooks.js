// define hooks for live view
let Hooks = {};

import Chart from "chart.js";

Hooks.LotkaVolterraChart = {
  mounted() {
    const chart = new Chart(this.el, {
      type: "line",
      data: {
        labels: [],
        datasets: [{
          label: "Vegetation",
          borderColor: "rgba(59, 120, 59, 0.8)",
          backgroundColor: "rgba(44, 160, 44, 0.2)",
          lineTension: 0,
          borderWidth: 2,
          data: []
        }]
      },
      options: {
        scales: {
          yAxes: [{
            ticks: {
              beginAtZero: true
            }
          }]
        }
      }
    });

    this.handleEvent("update-chart", (data) => {
      let vegetation = Number(data.vegetation).toFixed(2);
      chart.data.labels.push(data.x_axe);
      chart.data.datasets[0].data.push(vegetation);
      chart.update();
    });
  }
};

export default Hooks;
