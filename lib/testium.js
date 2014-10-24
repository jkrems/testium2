
/*
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
 */
var Assertions, Browser, RESOURCE_TIMEOUT, WebDriver, applyMixin, applyMixins, assert, cachedDriver, clone, config, debug, each, ensureDesiredCapabilities, extend, getBrowser, path, processes, _ref;

path = require('path');

assert = require('assertive');

debug = require('debug')('testium:testium');

_ref = require('lodash'), each = _ref.each, extend = _ref.extend, clone = _ref.clone;

config = require('./config');

Browser = require('./browser');

Assertions = require('./assert');

processes = require('./processes')();

WebDriver = require('webdriver-http-sync');

applyMixin = function(obj, mixin) {
  return extend(obj, mixin);
};

applyMixins = function(obj, mixins) {
  if (mixins == null) {
    mixins = [];
  }
  return each(mixins, function(mixin) {
    var mixinFile;
    debug('Applying mixin to %s', obj.constructor.name, mixin);
    mixinFile = path.resolve(process.cwd(), mixin);
    return applyMixin(obj, require(mixinFile));
  });
};

cachedDriver = null;

RESOURCE_TIMEOUT = 'phantomjs.page.settings.resourceTimeout';

ensureDesiredCapabilities = function(config) {
  var capabilities, _ref1;
  capabilities = (_ref1 = config.desiredCapabilities) != null ? _ref1 : {};
  if (capabilities.browserName == null) {
    capabilities.browserName = config.browser;
  }
  switch (capabilities.browserName) {
    case 'phantomjs':
      if (capabilities[RESOURCE_TIMEOUT] == null) {
        capabilities[RESOURCE_TIMEOUT] = 2500;
      }
  }
  return config.desiredCapabilities = capabilities;
};

getBrowser = function(options, done) {
  var keepCookies, reuseSession, _ref1, _ref2;
  if (typeof options === 'function') {
    done = options;
    options = {};
  }
  reuseSession = (_ref1 = options.reuseSession) != null ? _ref1 : true;
  keepCookies = (_ref2 = options.keepCookies) != null ? _ref2 : false;
  assert.hasType('getBrowser requires a callback, please check the docs for breaking changes', Function, done);
  ensureDesiredCapabilities(config);
  return processes.ensureRunning(config, (function(_this) {
    return function(err, results) {
      var createBrowser, createDriver, proxy, selenium;
      if (err != null) {
        return done(err);
      }
      selenium = results.selenium, proxy = results.proxy;
      createDriver = function() {
        var desiredCapabilities, driverUrl;
        driverUrl = selenium.driverUrl;
        desiredCapabilities = config.desiredCapabilities;
        debug('WebDriver(%j)', driverUrl, desiredCapabilities);
        return cachedDriver = new WebDriver(driverUrl, desiredCapabilities);
      };
      createBrowser = function() {
        var browser, driver, useCachedDriver, _ref3, _ref4;
        useCachedDriver = reuseSession && (cachedDriver != null);
        driver = useCachedDriver ? cachedDriver : createDriver();
        browser = new Browser(driver, proxy.baseUrl, 'http://127.0.0.1:4446');
        browser.init({
          skipPriming: useCachedDriver,
          keepCookies: keepCookies
        });
        applyMixins(browser, (_ref3 = config.mixins) != null ? _ref3.browser : void 0);
        applyMixins(browser.assert, (_ref4 = config.mixins) != null ? _ref4.assert : void 0);
        return browser;
      };
      return done(null, createBrowser());
    };
  })(this));
};

exports.getBrowser = getBrowser;

exports.Browser = Browser;

exports.Assertions = Assertions;
