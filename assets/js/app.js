// We import the CSS which is extracted to its own file by esbuild.
// Remove this line if you add a your own CSS build pipeline (e.g postcss).
import "../css/app.css";

// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html";
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import topbar from "../vendor/topbar";

const Hooks = {};


Hooks.Ping = {
    mounted() {
        this.nextN = 0;
        this.pongCount = 0;
        this.totalRoundTripTime = 0;

        window.addEventListener("keydown", this.sendPing.bind(this));
        this.el.querySelector("#measure-button")
            .addEventListener("mousedown", this.sendPing.bind(this));
        this.handleEvent("pong", this.onPong.bind(this));
    },
    sendPing() {
        let n = this.nextN;
        this.nextN++;
        this.pushEvent("ping", { n: n, at: performance.now() });
    },
    onPong(payload) {
        // Calculate it

        let roundTripTime = performance.now() - payload.pingAt;
        let n = payload.n;

        this.pongCount += 1;
        this.totalRoundTripTime += roundTripTime;
        let roundTripAvgTime = Math.round(this.totalRoundTripTime / this.pongCount);

        // Display it

        this.el.querySelector("#round-trip-avg").innerText = roundTripAvgTime;

        let nElem = document.createElement("td");
        nElem.innerText = n;

        let timeElem = document.createElement("td");
        timeElem.innerText = roundTripTime;

        let row = document.createElement("tr");
        row.append(nElem);
        row.append(timeElem);
        row.append(document.createElement("td"));

        let parent = this.el.querySelector("#timings-table-body");
        parent.append(row);
        window.requestAnimationFrame(() => row.scrollIntoView());
    }
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, { hooks: Hooks, params: { _csrf_token: csrfToken } });

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });
window.addEventListener("phx:page-loading-start", info => topbar.show());
window.addEventListener("phx:page-loading-stop", info => topbar.hide());

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;

