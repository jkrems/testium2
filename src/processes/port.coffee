###
Copyright (c) 2014, Groupon, Inc.
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:

Redistributions of source code must retain the above copyright notice,
this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.

Neither the name of GROUPON nor the names of its contributors may be
used to endorse or promote products derived from this software without
specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
###

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
