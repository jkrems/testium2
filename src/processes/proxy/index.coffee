{spawnServer} = require '../server'
{findOpenPort} = require '../port'

spawnProxy = (config, callback) ->
  {appPort} = config

  port = 4445
  nodejs = process.execPath
  proxyModule = require.resolve './child'
  args = [ proxyModule, appPort ]
  spawnServer 'proxy', nodejs, args, {port}, (error, proxy) ->
    return callback(error) if error?
    callback null, proxy

module.exports = spawnProxy
