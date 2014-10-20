debug = require('debug')('testium:processes:application')

spawnApplication = (config, callback) ->
  unless config.launch
    return callback()

  debug 'Launching application'
  callback new Error('Not implemented')

module.exports = spawnApplication
