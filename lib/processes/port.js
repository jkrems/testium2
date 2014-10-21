
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
var createServer, findOpenPort, isAvailable, portscanner, procError, waitFor;

createServer = require('net').createServer;

portscanner = require('portscanner');

isAvailable = function(port, callback) {
  return portscanner.checkPortStatus(port, '127.0.0.1', function(error, status) {
    if (error != null) {
      return callback(error);
    }
    return callback(null, status === 'closed');
  });
};

procError = function(proc) {
  var message, _ref;
  message = "Process \"" + proc.name + "\" crashed. See log at: " + proc.logPath + ".";
  if (((_ref = proc.error) != null ? _ref.length : void 0) > 0) {
    message += "\n" + (proc.error.trim());
  }
  return new Error(message);
};

waitFor = function(proc, port, timeout, callback) {
  var check, error, startTime;
  if (proc.exitCode != null) {
    error = procError(proc);
    return callback(error);
  }
  startTime = Date.now();
  check = function() {
    return portscanner.checkPortStatus(port, '127.0.0.1', function(error, status) {
      var timedOut;
      if (error != null) {
        console.error(error.stack);
      }
      if (proc.exitCode != null) {
        error = procError(proc);
        return callback(error);
      }
      if ((error != null) || status === 'closed') {
        if ((Date.now() - startTime) >= timeout) {
          timedOut = true;
          return callback(null, timedOut);
        }
        return setTimeout(check, 100);
      } else {
        return callback();
      }
    });
  };
  return check();
};

findOpenPort = function(callback) {
  var server;
  server = createServer();
  server.on('error', callback);
  return server.listen(0, function() {
    var port;
    port = this.address().port;
    server.on('close', function() {
      return callback(null, port);
    });
    return server.close();
  });
};

module.exports = {
  isAvailable: isAvailable,
  waitFor: waitFor,
  findOpenPort: findOpenPort
};
