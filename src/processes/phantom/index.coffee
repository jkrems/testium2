{spawnServer} = require '../server'
{findOpenPort} = require '../port'
initLogs = require '../../logs'

spawnPhantom = (config, callback) ->
  logs = initLogs config

  findOpenPort (error, port) ->
    return callback(error) if error?
    args = [
      "--webdriver=#{port}"
      '--webdriver-loglevel=DEBUG'
    ]
    spawnServer logs, 'phantomjs', 'phantomjs', args, {port}, (error, phantom) ->
      return callback(error) if error?
      callback null, phantom

module.exports = spawnPhantom
