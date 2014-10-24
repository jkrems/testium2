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

{spawn} = require 'child_process'

async = require 'async'
{extend} = require 'lodash'
debug = require('debug')('testium:processes')

{findOpenPort} = require './port'
spawnProxy = require './proxy'
spawnPhantom = require './phantom'
spawnSelenium = require './selenium'
spawnApplication = require './application'

ensureAppPort = (config, done) ->
  if config.appPort == 0
    findOpenPort (err, port) ->
      return done(err) if err?
      config.appPort = port
      done()
  else
    done()

initProcesses = ->
  cached = null

  ensureRunning: (config, callback) ->
    if cached?
      debug 'Returning cached processes'
      return process.nextTick ->
        callback(cached.error, cached.results)

    debug 'Launching processes'
    async.auto {
      ensureAppPort: (done) -> ensureAppPort(config, done)

      selenium: (done) ->
        if config.desiredCapabilities.browserName == 'phantomjs'
          spawnPhantom(config, done)
        else
          spawnSelenium(config, done)

      proxy: [ 'ensureAppPort', (done) ->
        spawnProxy(config, done)
      ]

      application: [ 'ensureAppPort', (done) ->
        spawnApplication(config, done)
      ]
    }, (error, results) ->
      cached = {error, results}
      callback error, results

module.exports = extend initProcesses, {
  spawnPhantom
  spawnProxy
  spawnApplication
}
