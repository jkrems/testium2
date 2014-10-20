assert = require 'assertive'
debug = require('debug')('testium:testium')

Browser = require './browser'
processes = require('./processes')()

WebDriver = require 'webdriver-http-sync'

getBrowser = (config, done) ->
  assert.hasType '''
    getBrowser requires a callback, please check the docs for breaking changes
  ''', Function, done

  processes.ensureRunning config, (err, results) =>
    return done(err) if err?
    {phantom, proxy} = results

    driverUrl = "#{phantom.baseUrl}/wd/hub"
    desiredCapabilities = browserName: 'phantomjs'
    debug 'WebDriver(%j)', driverUrl
    driver = new WebDriver driverUrl, desiredCapabilities

    browser = new Browser driver, proxy.baseUrl, 'http://127.0.0.1:4446'
    browser.navigateTo '/testium-priming-load'

    done null, browser

exports.getBrowser = getBrowser
