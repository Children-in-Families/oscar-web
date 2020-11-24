import * as Sentry from "@sentry/browser";

// same DSN like production, but without http passowrd, could also be injected like the SENTRY_RELEASE
Sentry.init({
  dsn: window.SENTRY_DSN,
  release: window.SENTRY_RELEASE,
  environment: "production",
});
// to allow easy access from all areas append to window:
window.Sentry = Sentry;
