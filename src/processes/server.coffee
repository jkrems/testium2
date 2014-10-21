{spawn} = require 'child_process'

{extend, omit} = require 'lodash'
debug = require('debug')('testium:processes')

{waitFor} = require './port'

spawnServer = (logs, name, cmd, args, opts, cb) ->
  {port, timeout} = opts
  timeout ?= 1000

  logs.openLogFile name, 'w+', (error, results) ->
    return cb(error) if error?
    {fd: logHandle, filename: logPath} = results

    spawnOpts = extend {
      stdio: [ 'ignore', logHandle, logHandle ]
    }, omit(opts, 'port', 'timeout')
    child = spawn cmd, args, spawnOpts
    child.baseUrl = "http://127.0.0.1:#{port}"
    child.logPath = logPath
    child.logHandle = logHandle

    process.on 'exit', ->
      try child.kill()

    process.on 'uncaughtException', (error) ->
      try child.kill()
      throw error

    debug 'start %s on port %s', name, port
    waitFor child, port, timeout, (error) ->
      debug 'started %s', name, error
      return cb(error) if error?
      cb null, child

module.exports = { spawnServer }
