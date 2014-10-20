async = require 'async'
readPackageJson = require 'read-package-json'
debug = require('debug')('testium:processes:application')
{defaults} = require 'lodash'

{spawnServer} = require '../server'
{findOpenPort} = require '../port'

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
  {launch, launchTimeout: timeout, appPort: port} = config

  return callback() unless launch

  getLaunchCommand config, (error, launchCommand) ->
    return callback(error) if error

    args = launchCommand.split /[\s]+/g
    cmd = args.shift()
    debug 'Launching application', cmd, args

    env = defaults {
      NODE_ENV: 'test'
      PORT: port
      PATH: "./node_modules/.bin:#{process.env.PATH}"
    }, process.env

    opts = {port, env, timeout}
    spawnServer 'application', cmd, args, opts, (error, app) ->
      return callback(error) if error?
      callback null, app

module.exports = spawnApplication
