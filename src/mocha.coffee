debug = require('debug')('testium:mocha')

config = require './config'
{getBrowser} = require './testium'

setMochaTimeouts = (obj) ->
  obj.timeout +config.mocha.timeout

deepMochaTimeouts = (suite) ->
  setMochaTimeouts suite
  suite.suites.forEach deepMochaTimeouts
  suite._beforeEach.forEach setMochaTimeouts
  suite._beforeAll.forEach setMochaTimeouts
  suite._afterEach.forEach setMochaTimeouts
  suite._afterAll.forEach setMochaTimeouts

injectBrowser = (done) ->
  debug 'Overriding mocha timeouts', config.mocha
  deepMochaTimeouts @_runnable.parent
  setMochaTimeouts this

  getBrowser config, (err, @browser) =>
    done err

module.exports = injectBrowser
