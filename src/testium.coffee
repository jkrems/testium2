###
Copyright (c) 2014, Groupon, Inc.
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:

Redistributions of source code must retain the above copyright notice,
this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.

Neither the name of GROUPON nor the names of its contributors may be
used to endorse or promote products derived from this software without
specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
###

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
  keepCookies = options.keepCookies ? false

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
      browser.init { skipPriming: useCachedDriver, keepCookies }

      applyMixins browser, config.mixins?.browser
      applyMixins browser.assert, config.mixins?.assert

      browser

    done null, createBrowser()

exports.getBrowser = getBrowser
exports.Browser = Browser
exports.Assertions = Assertions
