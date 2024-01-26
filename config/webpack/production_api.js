process.env.NODE_ENV = process.env.NODE_ENV || "production_api";

const environment = require("./environment");

module.exports = environment.toWebpackConfig();
