rc = require 'rc'

getDefaults = ->
  browser: 'phantomjs'
  mocha:
    timeout: 20000

module.exports = rc 'testium', getDefaults()
