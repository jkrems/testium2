async = require 'async'
readPackageJson = require 'read-package-json'
debug = require('debug')('testium:processes:application')
{defaults} = require 'lodash'

{spawnServer} = require '../server'
{findOpenPort, isAvailable} = require '../port'
initLogs = require '../../logs'

NO_LAUNCH_COMMAND_ERROR =
  'Not launch command found, please add scripts.start to package.json'

getLaunchCommand = (config, callback) ->
  if config.launchCommand
    return callback null, config.launchCommand

  debug 'Trying to use package.json:scripts.start'
  pkgJsonPath = "#{config.appDirectory}/package.json"
  readPackageJson pkgJsonPath, (error, pkgJson) ->
    return callback(error) if error?

    debug 'Loaded from package json', pkgJson.scripts?.start

    unless pkgJson.scripts?.start
      return cb new Error NO_LAUNCH_COMMAND_ERROR

    callback null, pkgJson.scripts.start

spawnApplication = (config, callback) ->
  {launch, launchTimeout: timeout} = config

  unless launch
    return isAvailable config.appPort, (error, available) ->
      return callback() unless available
      callback new Error "App not listening on #{config.appPort}"

  logs = initLogs config

  async.auto {
    port: (done) ->
      port = config.appPort
      isAvailable port, (error, available) ->
        return done(null, port) if available
        done new Error "Something is already listening on #{port}"

    launchCommand: (done) ->
      getLaunchCommand config, done

    app: [ 'port', 'launchCommand', (done, {port, launchCommand}) ->
      args = launchCommand.split /[\s]+/g
      cmd = args.shift()
      debug 'Launching application', cmd, args

      env = defaults {
        NODE_ENV: 'test'
        PORT: port
        PATH: "./node_modules/.bin:#{process.env.PATH}"
      }, process.env

      opts = {port, env, timeout}
      spawnServer logs, 'application', cmd, args, opts, done
    ]
  }, (error, {app}) ->
    callback error, app

module.exports = spawnApplication
