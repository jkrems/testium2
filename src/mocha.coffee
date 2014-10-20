debug = require('debug')('testium:mocha')

config = require './config'
{getBrowser} = require './testium'

injectBrowser = (done) ->
  debug 'Setting mocha timeout', config.mocha
  @timeout +config.mocha.timeout

  getBrowser config, (err, @browser) =>
    done(err)

module.exports = injectBrowser
