// define hooks for live view
let Hooks = {};

import Chart from "chart.js";

Hooks.GameOfLife = {
  mounted() {
    this.handleEvent("update-game-of-life", (data) => {
      data.changes.forEach(([x, y, cell]) => {
        let css = document.getElementById(`cell_${x}_${y}`).classList;
        if (cell) {
          css.add("game-of-life-active");
        } else {
          css.remove("game-of-life-active");
        }
      });
    });
  },
};

Hooks.LotkaVolterraChart = {
  mounted() {
    const chart = new Chart(this.el, {
      type: "line",
      data: {
        labels: [],
        datasets: [
          {
            label: "Vegetation",
            borderColor: "rgb(46, 160, 67, 0.8)",
            backgroundColor: "rgba(44, 160, 44, 0.2)",
            lineTension: 0,
            borderWidth: 2,
            data: [],
          },
          {
            label: "Herbivore",
            borderColor: "rgb(219, 109, 40, 0.8)",
            backgroundColor: "rgb(166, 89, 78, 0.2)",
            lineTension: 0,
            borderWidth: 2,
            data: [],
          },
          {
            label: "Predator",
            borderColor: "rgb(248, 81, 73, 0.8)",
            backgroundColor: "rgb(256, 89, 78, 0.2)",
            lineTension: 0,
            borderWidth: 2,
            data: [],
          },
        ],
      },
      options: {
        scales: {
          yAxes: [
            {
              ticks: {
                beginAtZero: true,
              },
            },
          ],
        },
      },
    });

    this.handleEvent("update-chart", (data) => {
      let vegetation = Number(data.vegetation).toFixed(2);
      let herbivore = Number(data.herbivore).toFixed(2);
      let predator = Number(data.predator).toFixed(2);
      chart.data.labels.push(data.x_axis);
      chart.data.datasets[0].data.push(vegetation);
      chart.data.datasets[1].data.push(herbivore);
      chart.data.datasets[2].data.push(predator);
      chart.update();
    });
  },
};

export default Hooks;
