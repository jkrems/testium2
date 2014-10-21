
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
var config, debug, deepMochaTimeouts, getBrowser, injectBrowser, setMochaTimeouts;

debug = require('debug')('testium:mocha');

config = require('./config');

getBrowser = require('./testium').getBrowser;

setMochaTimeouts = function(obj) {
  obj.timeout(+config.mocha.timeout);
  return obj.slow(+config.mocha.slow);
};

deepMochaTimeouts = function(suite) {
  setMochaTimeouts(suite);
  suite.suites.forEach(deepMochaTimeouts);
  suite.tests.forEach(setMochaTimeouts);
  suite._beforeEach.forEach(setMochaTimeouts);
  suite._beforeAll.forEach(setMochaTimeouts);
  suite._afterEach.forEach(setMochaTimeouts);
  return suite._afterAll.forEach(setMochaTimeouts);
};

injectBrowser = function(options) {
  if (options == null) {
    options = {};
  }
  return function(done) {
    var initialTimeout;
    debug('Overriding mocha timeouts', config.mocha);
    deepMochaTimeouts(this._runnable.parent);
    initialTimeout = +config.launchTimeout;
    initialTimeout += +config.mocha.timeout;
    this.timeout(initialTimeout);
    return getBrowser(options, (function(_this) {
      return function(err, browser) {
        _this.browser = browser;
        return done(err);
      };
    })(this));
  };
};

module.exports = injectBrowser;
