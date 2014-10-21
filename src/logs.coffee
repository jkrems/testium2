fs = require 'fs'
path = require 'path'

debug = require('debug')('testium:logs')

module.exports = (config) ->
  {appDirectory, logDirectory} = config

  resolveLogFile = (name) ->
    path.resolve appDirectory, logDirectory, "#{name}.log"

  openLogFile = (name, flags, callback) ->
    filename = resolveLogFile name

    if typeof flags == 'function'
      callback = flags
      flags = 'w+'

    debug 'Opening log', filename
    fs.open filename, flags, (error, fd) ->
      return callback(error, {}) if error?
      callback null, {filename, fd}

  {openLogFile, resolveLogFile}
