
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
var NO_LAUNCH_COMMAND_ERROR, async, debug, defaults, findOpenPort, getLaunchCommand, initLogs, isAvailable, isTrulyTrue, readPackageJson, spawnApplication, spawnServer, _ref;

async = require('async');

readPackageJson = require('read-package-json');

debug = require('debug')('testium:processes:application');

defaults = require('lodash').defaults;

spawnServer = require('../server').spawnServer;

_ref = require('../port'), findOpenPort = _ref.findOpenPort, isAvailable = _ref.isAvailable;

initLogs = require('../../logs');

NO_LAUNCH_COMMAND_ERROR = 'Not launch command found, please add scripts.start to package.json';

getLaunchCommand = function(config, callback) {
  var pkgJsonPath;
  if (config.launchCommand) {
    return callback(null, config.launchCommand);
  }
  debug('Trying to use package.json:scripts.start');
  pkgJsonPath = "" + config.appDirectory + "/package.json";
  return readPackageJson(pkgJsonPath, function(error, pkgJson) {
    var _ref1, _ref2;
    if (error != null) {
      return callback(error);
    }
    debug('Loaded from package json', (_ref1 = pkgJson.scripts) != null ? _ref1.start : void 0);
    if (!((_ref2 = pkgJson.scripts) != null ? _ref2.start : void 0)) {
      return cb(new Error(NO_LAUNCH_COMMAND_ERROR));
    }
    return callback(null, pkgJson.scripts.start);
  });
};

isTrulyTrue = function(value) {
  return value === true || value === '1' || value === 'true';
};

spawnApplication = function(config, callback) {
  var launch, logs, timeout;
  launch = config.launch, timeout = config.launchTimeout;
  launch = isTrulyTrue(launch);
  if (!launch) {
    return isAvailable(config.appPort, function(error, available) {
      if (!available) {
        return callback();
      }
      return callback(new Error("App not listening on " + config.appPort));
    });
  }
  logs = initLogs(config);
  return async.auto({
    port: function(done) {
      var port;
      port = config.appPort;
      return isAvailable(port, function(error, available) {
        if (available) {
          return done(null, port);
        }
        return done(new Error("Something is already listening on " + port));
      });
    },
    launchCommand: function(done) {
      return getLaunchCommand(config, done);
    },
    app: [
      'port', 'launchCommand', function(done, _arg) {
        var args, cmd, env, launchCommand, opts, port;
        port = _arg.port, launchCommand = _arg.launchCommand;
        args = launchCommand.split(/[\s]+/g);
        cmd = args.shift();
        debug('Launching application', cmd, args);
        env = defaults({
          NODE_ENV: 'test',
          PORT: port,
          PATH: "./node_modules/.bin:" + process.env.PATH
        }, process.env);
        opts = {
          port: port,
          env: env,
          timeout: timeout
        };
        return spawnServer(logs, 'application', cmd, args, opts, done);
      }
    ]
  }, function(error, _arg) {
    var app;
    app = _arg.app;
    return callback(error, app);
  });
};

module.exports = spawnApplication;
