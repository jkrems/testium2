path = require 'path'

assert = require 'assertive'
debug = require('debug')('testium:testium')
{each, extend, clone} = require 'lodash'

config = require './config'
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

cachedDriver = null

getBrowser = (options, done) ->
  if typeof options == 'function'
    done = options
    options = {}

  reuseSession = options.reuseSession ? true

  assert.hasType '''
    getBrowser requires a callback, please check the docs for breaking changes
  ''', Function, done

  processes.ensureRunning config, (err, results) =>
    return done(err) if err?
    {phantom, proxy} = results

    createDriver = ->
      driverUrl = "#{phantom.baseUrl}/wd/hub"
      desiredCapabilities =
        browserName: 'phantomjs'
        'phantomjs.page.settings.resourceTimeout': 2500
      debug 'WebDriver(%j)', driverUrl, desiredCapabilities
      cachedDriver = new WebDriver driverUrl, desiredCapabilities

    createBrowser = ->
      useCachedDriver = reuseSession && cachedDriver?
      driver =
        if useCachedDriver then cachedDriver else createDriver()

      browser = new Browser driver, proxy.baseUrl, 'http://127.0.0.1:4446'

      unless useCachedDriver
        browser.navigateTo '/testium-priming-load'
        debug 'Browser was primed'
      else
        debug 'Browser was already primed'

      debug 'Clearing cookies for clean state'
      browser.clearCookies()

      # default to reasonable size
      # fixes some phantomjs element size/position reporting
      browser.setPageSize
        height: 768
        width: 1024

      applyMixins browser, config.mixins?.browser
      applyMixins browser.assert, config.mixins?.assert

      browser

    done null, createBrowser()

exports.getBrowser = getBrowser
exports.Browser = Browser
exports.Assertions = Assertions
