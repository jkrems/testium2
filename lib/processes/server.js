
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
var debug, extend, omit, spawn, spawnServer, waitFor, _ref;

spawn = require('child_process').spawn;

_ref = require('lodash'), extend = _ref.extend, omit = _ref.omit;

debug = require('debug')('testium:processes');

waitFor = require('./port').waitFor;

spawnServer = function(logs, name, cmd, args, opts, cb) {
  var port, timeout;
  port = opts.port, timeout = opts.timeout;
  if (timeout == null) {
    timeout = 1000;
  }
  return logs.openLogFile(name, 'w+', function(error, results) {
    var child, logHandle, logPath, spawnOpts;
    if (error != null) {
      return cb(error);
    }
    logHandle = results.fd, logPath = results.filename;
    spawnOpts = extend({
      stdio: ['ignore', logHandle, logHandle]
    }, omit(opts, 'port', 'timeout'));
    child = spawn(cmd, args, spawnOpts);
    child.baseUrl = "http://127.0.0.1:" + port;
    child.logPath = logPath;
    child.logHandle = logHandle;
    child.name = name;
    process.on('exit', function() {
      var err;
      try {
        return child.kill('SIGINT');
      } catch (_error) {
        err = _error;
        return console.error(err.stack);
      }
    });
    process.on('uncaughtException', function(error) {
      var err;
      try {
        child.kill('SIGINT');
      } catch (_error) {
        err = _error;
        console.error(err.stack);
      }
      throw error;
    });
    debug('start %s on port %s', name, port);
    return waitFor(child, port, timeout, function(error) {
      debug('started %s', name, error);
      if (error != null) {
        return cb(error);
      }
      return cb(null, child);
    });
  });
};

module.exports = {
  spawnServer: spawnServer
};
