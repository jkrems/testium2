
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
var BIN_PATH, SELENIUM_TIMEOUT, async, createSeleniumArguments, ensureBinaries, ensureSeleniumListening, findOpenPort, http, initLogs, path, spawnSelenium, spawnServer;

path = require('path');

http = require('http');

ensureBinaries = require('selenium-download').ensure;

async = require('async');

spawnServer = require('../server').spawnServer;

findOpenPort = require('../port').findOpenPort;

initLogs = require('../../logs');

BIN_PATH = path.join(__dirname, '..', '..', '..', 'bin');

SELENIUM_TIMEOUT = 90000;

ensureSeleniumListening = function(driverUrl, callback) {
  var req;
  req = http.get("" + driverUrl + "/status", function(response) {
    return callback(null, {
      driverUrl: driverUrl
    });
  });
  return req.on('error', callback);
};

createSeleniumArguments = function() {
  var chromeArgs, chromeDriverPath, firefoxProfilePath;
  chromeDriverPath = path.join(BIN_PATH, 'chromedriver');
  chromeArgs = ['--disable-application-cache', '--media-cache-size=1', '--disk-cache-size=1', '--disk-cache-dir=/dev/null', '--disable-cache', '--disable-desktop-notifications'].join(' ');
  firefoxProfilePath = path.join(__dirname, './firefox_profile.js');
  return ["-Dwebdriver.chrome.driver=" + chromeDriverPath, "-Dwebdriver.chrome.args=\"" + chromeArgs + "\"", '-firefoxProfileTemplate', firefoxProfilePath, '-ensureCleanSession', '-debug'];
};

spawnSelenium = function(config, callback) {
  var logs;
  if (config.seleniumServerUrl) {
    return ensureSeleniumListening(config.seleniumServerUrl, callback);
  }
  logs = initLogs(config);
  return async.auto({
    port: findOpenPort,
    binaries: function(done) {
      return ensureBinaries(BIN_PATH, done);
    },
    selenium: [
      'port', 'binaries', function(done, _arg) {
        var args, jarPath, options, port;
        port = _arg.port;
        jarPath = path.join(BIN_PATH, 'selenium.jar');
        args = ['-Xmx256m', '-jar', jarPath, '-port', "" + port].concat(createSeleniumArguments());
        options = {
          port: port,
          timeout: SELENIUM_TIMEOUT
        };
        return spawnServer(logs, 'selenium', 'java', args, options, done);
      }
    ]
  }, function(error, _arg) {
    var port, selenium;
    selenium = _arg.selenium, port = _arg.port;
    selenium.driverUrl = "" + selenium.baseUrl + "/wd/hub";
    return callback(error, selenium);
  });
};

module.exports = spawnSelenium;
