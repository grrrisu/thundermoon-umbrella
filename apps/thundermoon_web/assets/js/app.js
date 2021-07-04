import css from "../css/app.css";

import "phoenix_html";

import { Socket } from "phoenix";
import LiveSocket from "phoenix_live_view";

import Alpine from "alpinejs";
window.Alpine = Alpine;

import Hooks from "./live_view_hooks.js";

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");

let liveSocket = new LiveSocket("/live", Socket, {
  dom: {
    onBeforeElUpdated(from, to) {
      if (from._x_dataStack) {
        window.Alpine.clone(from, to);
      }
    },
  },
  hooks: Hooks,
  params: { _csrf_token: csrfToken },
});

import NProgress from "nprogress";

// Show progress bar on live navigation and form submits
window.addEventListener("phx:page-loading-start", (info) => NProgress.start());
window.addEventListener("phx:page-loading-stop", (info) => NProgress.done());

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)
window.liveSocket = liveSocket;
