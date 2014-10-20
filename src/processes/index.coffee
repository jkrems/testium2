{spawn} = require 'child_process'

async = require 'async'
{extend} = require 'lodash'
debug = require('debug')('testium:processes')

spawnProxy = require './proxy'
spawnPhantom = require './phantom'
spawnApplication = require './application'

initProcesses = (config) ->
  cached = null

  ensureRunning: (config, callback) ->
    if cached?
      debug 'Returning cached processes'
      return process.nextTick ->
        callback(cached.error, cached.results)

    debug 'Launching processes'
    async.auto {
      proxy: (done) -> spawnProxy(config, done)
      phantom: spawnPhantom
      application: (done) -> spawnApplication(config, done)
    }, (error, results) ->
      cached = {error, results}
      callback error, results

module.exports = extend initProcesses, {
  spawnPhantom
  spawnProxy
  spawnApplication
}
