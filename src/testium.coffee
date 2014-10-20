path = require 'path'

assert = require 'assertive'
debug = require('debug')('testium:testium')
{each, extend} = require 'lodash'

Browser = require './browser'
Assertions = require './assert'
processes = require('./processes')()

WebDriver = require 'webdriver-http-sync'

applyMixin = (obj, mixin) ->
  extend obj, mixin

applyMixins = (obj, mixins = []) ->
  each mixins, (mixin) ->
    debug 'Applying mixin to %s', obj.constructor.name, mixin
    mixinFile = path.resolve process.cwd(), mixin
    applyMixin obj, require mixinFile

getBrowser = (config, done) ->
  if typeof config == 'function'
    done = config
    config = require './config'

  assert.hasType '''
    getBrowser requires a callback, please check the docs for breaking changes
  ''', Function, done

  processes.ensureRunning config, (err, results) =>
    return done(err) if err?
    {phantom, proxy} = results

    driverUrl = "#{phantom.baseUrl}/wd/hub"
    desiredCapabilities =
      browserName: 'phantomjs'
      'phantomjs.page.settings.resourceTimeout': 2500
    debug 'WebDriver(%j)', driverUrl, desiredCapabilities
    driver = new WebDriver driverUrl, desiredCapabilities

    browser = new Browser driver, proxy.baseUrl, 'http://127.0.0.1:4446'
    browser.navigateTo '/testium-priming-load'
    debug 'Browser was primed'

    # default to reasonable size
    # fixes some phantomjs element size/position reporting
    browser.setPageSize
      height: 768
      width: 1024

    debug 'Clearing cookies for clean state'
    browser.clearCookies()

    applyMixins browser, config.mixins?.browser
    applyMixins browser.assert, config.mixins?.assert

    done null, browser

exports.getBrowser = getBrowser
exports.Browser = Browser
exports.Assertions = Assertions
