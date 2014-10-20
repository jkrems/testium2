debug = require('debug')('testium:processes:proxy')

{spawnServer} = require '../server'
{findOpenPort} = require '../port'

spawnProxy = (callback) ->
  findOpenPort (error, port) ->
    return callback(error) if error?
    port = 4445
    appPort = 3070
    debug 'start proxy on port %s', port
    nodejs = process.execPath
    proxyModule = require.resolve './child'
    args = [ proxyModule, appPort ]
    spawnServer 'proxy', nodejs, args, port, (error, proxy) ->
      return callback(error) if error?
      callback null, proxy

module.exports = spawnProxy
