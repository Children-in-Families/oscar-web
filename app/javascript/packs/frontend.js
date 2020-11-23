const Appsignal = require("@appsignal/javascript").default;
const appsignal = new Appsignal({
  key: window.appsignalFrontendKey,
});
window.appsignal = appsignal;
window.onerror = function (msg, url, line, col, error) {
  console.log("onerror triggered");
  if (error instanceof Error) {
    appsignal.sendError(error);
    return false;
  }
};

window.onunhandledrejection = function (msg, url, line, col, error) {
  console.log("onunhandledrejection triggered");
  if (error instanceof Error) {
    appsignal.sendError(error);
    return false;
  }
};
