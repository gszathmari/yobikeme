if process.env.ROLLBAR_ACCESS_TOKEN
  rollbar = require 'rollbar'
  options =
    exitOnUncaughtException: true

  rollbar.handleUncaughtExceptions process.env.ROLLBAR_ACCESS_TOKEN, options
