{spawn} = require 'child_process'

{waitFor} = require './port'

spawnServer = (name, cmd, args, port, cb) ->
  logPath = "#{name}.log"
  require('fs').open logPath, 'w+', (err, logHandle) ->
    return cb(err) if err?
    child = spawn cmd, args, {
      stdio: [ 'ignore', logHandle, logHandle ]
    }
    child.baseUrl = "http://127.0.0.1:#{port}"
    child.logPath = logPath
    child.logHandle = logHandle

    process.on 'exit', ->
      try child.kill()

    process.on 'uncaughtException', (error) ->
      try child.kill()
      throw error

    waitFor child, port, 1000, (err) ->
      return cb(err) if err?
      cb null, child

module.exports = { spawnServer }
