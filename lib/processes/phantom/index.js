// Generated by CoffeeScript 1.8.0
var debug, findOpenPort, spawnPhantom, spawnServer;

debug = require('debug')('testium:processes:phantom');

spawnServer = require('../server').spawnServer;

findOpenPort = require('../port').findOpenPort;

spawnPhantom = function(callback) {
  return findOpenPort(function(error, port) {
    var args;
    if (error != null) {
      return callback(error);
    }
    debug('start phantom on port %s', port);
    args = ['--webdriver=' + port];
    return spawnServer('phantomjs', 'phantomjs', args, port, function(error, phantom) {
      if (error != null) {
        return callback(error);
      }
      return callback(null, phantom);
    });
  });
};

module.exports = spawnPhantom;