require('dotenv').config();

module.exports = {
  development: {
    username: "postgres",
    password: "hb",
    database: "microservice",
    host: "127.0.0.1",
    dialect: "postgres"
  },
  test: {
    username: process.env.configUsername,
    password: process.env.configPassword,
    database: process.env.configTestDb,
    host: process.env.configHost,
    dialect: process.env.configDialect
  },
  production: {
    use_env_variable: process.env.configEnvVar
  }
};
