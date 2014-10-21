{spawnServer} = require '../server'
{findOpenPort} = require '../port'
initLogs = require '../../logs'

spawnProxy = (config, callback) ->
  {appPort} = config

  logs = initLogs config

  port = 4445
  nodejs = process.execPath
  proxyModule = require.resolve './child'
  args = [ proxyModule, appPort ]
  spawnServer logs, 'proxy', nodejs, args, {port}, (error, proxy) ->
    return callback(error) if error?
    callback null, proxy

module.exports = spawnProxy
