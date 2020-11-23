const Appsignal = require("@appsignal/javascript").default;
const appsignal = new Appsignal({
  key: window.appsignalFrontendKey,
});
window.appsignal = appsignal;
window.onerror = function (msg, url, line, col, error) {
  if (error instanceof Error && appsignal) {
    console.log("onerror triggered");
    appsignal.sendError(error);
    return false;
  }
};

window.onunhandledrejection = function (msg, url, line, col, error) {
  if (error instanceof Error && appsignal) {
    console.log("onunhandledrejection triggered");
    appsignal.sendError(error);
    return false;
  }
};
