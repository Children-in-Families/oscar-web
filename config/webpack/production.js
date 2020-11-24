process.env.NODE_ENV = process.env.NODE_ENV || "production";

const environment = require("./environment");

const SentryCliPlugin = require("@sentry/webpack-plugin");

const fs = require("fs");

// Again, getting the release here at this point, depends on your setup!
const release = fs.readFileSync("GIT_REVISION").toString();

environment.plugins.append(
  "sentry",
  new SentryCliPlugin({
    release,
    // what folders to scan for sources
    include: ["app/javascript", "public/assets"],
    // ignore
    ignore: ["node_modules", "webpack.config.js", "vendor"],
    // also set the last commit for the current release
    setCommits: {
      commit: release,
      // link that to your gitlab/github repository, to get the correct name
      //   head to Sentry -> Organisation settings -> Repos and take the name verbatim, no url!
      //   in our case, with self hosted Gitlab, it looked like this
      repo: "developers / Myrepos",
    },
  })
);

module.exports = environment.toWebpackConfig();
