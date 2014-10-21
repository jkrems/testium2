debug = require('debug')('testium:mocha')

config = require './config'
{getBrowser} = require './testium'

setMochaTimeouts = (obj) ->
  obj.timeout +config.mocha.timeout
  obj.slow +config.mocha.slow

deepMochaTimeouts = (suite) ->
  setMochaTimeouts suite
  suite.suites.forEach deepMochaTimeouts
  suite.tests.forEach setMochaTimeouts
  suite._beforeEach.forEach setMochaTimeouts
  suite._beforeAll.forEach setMochaTimeouts
  suite._afterEach.forEach setMochaTimeouts
  suite._afterAll.forEach setMochaTimeouts

injectBrowser = (options = {}) -> (done) ->
  debug 'Overriding mocha timeouts', config.mocha
  deepMochaTimeouts @_runnable.parent

  initialTimeout = +config.launchTimeout
  initialTimeout += +config.mocha.timeout
  @timeout initialTimeout

  getBrowser options, (err, @browser) => done err

module.exports = injectBrowser
