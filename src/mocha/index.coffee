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

debug = require('debug')('testium:mocha')

config = require '../config'
{getBrowser} = require '../testium'
takeScreenshotOnFailure = require './screenshot'

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

closeBrowser = (browser) ->
  (done) ->
    browser.close (error) ->
      return done() unless error?
      error.message = "#{error.message} (while closing browser)"
      done error

CLOSE_BROWSER = 'closeBrowser'
CLOSE_BROWSER_PATTERN = /hook: closeBrowser$/
isCloseBrowserHook = (hook) ->
  CLOSE_BROWSER_PATTERN.test hook.title

addCloseBrowserHook = (suite, browser) ->
  return if suite._afterAll.some isCloseBrowserHook
  suite.afterAll CLOSE_BROWSER, closeBrowser(browser)

getRootSuite = (suite) ->
  if suite.parent
    getRootSuite suite.parent
  else
    suite

DEFAULT_TITLE = '"before all" hook'
BETTER_TITLE =  '"before all" hook: Testium setup hook'
injectBrowser = (options = {}) -> (done) ->
  if @_runnable.title == DEFAULT_TITLE
    @_runnable.title = BETTER_TITLE

  debug 'Overriding mocha timeouts', config.mocha
  suite = @_runnable.parent
  deepMochaTimeouts suite

  initialTimeout = +config.launchTimeout
  initialTimeout += +config.mocha.timeout
  @timeout initialTimeout

  reuseSession = options.reuseSession ?= true

  getBrowser options, (err, @browser) =>
    screenshotDirectory = config.screenshotDirectory
    if screenshotDirectory
      screenshotDirectory =
        path.resolve config.appDirectory, screenshotDirectory

      afterEachHook = takeScreenshotOnFailure screenshotDirectory
      suite.afterEach 'takeScreenshotOnFailure', afterEachHook

    browserScopeSuite =
      if reuseSession
        getRootSuite suite
      else suite

    addCloseBrowserHook browserScopeSuite, browser

    done err

module.exports = injectBrowser
