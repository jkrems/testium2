{spawnServer} = require '../server'
{findOpenPort} = require '../port'

spawnPhantom = (callback) ->
  findOpenPort (error, port) ->
    return callback(error) if error?
    args = [
      "--webdriver=#{port}"
      '--webdriver-loglevel=DEBUG'
    ]
    spawnServer 'phantomjs', 'phantomjs', args, {port}, (error, phantom) ->
      return callback(error) if error?
      callback null, phantom

module.exports = spawnPhantom
