{createServer} = require 'net'

portscanner = require 'portscanner'

isAvailable = (port, callback) ->
  portscanner.checkPortStatus port, '127.0.0.1', (error, status) ->
    return callback(error) if error?
    callback null, (status == 'closed')

procError = (proc) ->
  message = "Process \"#{proc.name}\" crashed. See log at: #{proc.logPath}."
  message += "\n#{proc.error.trim()}" if proc.error?.length > 0
  new Error message

waitFor = (proc, port, timeout, callback) ->
  if proc.exitCode?
    error = procError(proc)
    return callback(error)

  startTime = Date.now()
  check = ->
    portscanner.checkPortStatus port, '127.0.0.1', (error, status) ->
      console.error error.stack if error?

      if proc.exitCode?
        error = procError(proc)
        return callback(error)

      if error? || status == 'closed'
        if (Date.now() - startTime) >= timeout
          timedOut = true
          return callback(null, timedOut)
        setTimeout(check, 100)
      else
        callback()

  check()

findOpenPort = (callback) ->
  server = createServer()
  server.on 'error', callback
  server.listen 0, ->
    port = @address().port
    server.on 'close', -> callback(null, port)
    server.close()

module.exports = {isAvailable, waitFor, findOpenPort}
