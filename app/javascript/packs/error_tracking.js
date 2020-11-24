import * as Sentry from "@sentry/browser";

// same DSN like production, but without http passowrd, could also be injected like the SENTRY_RELEASE
Sentry.init({
  dsn:
    "https://19e7decf52684417b2414ba7fd360e45@o480860.ingest.sentry.io/5528553",
  release: window.SENTRY_RELEASE,
  environment: "production",
});
// to allow easy access from all areas append to window:
window.Sentry = Sentry;
