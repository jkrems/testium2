rc = require 'rc'

getDefaults = ->
  browser: 'phantomjs'
  mocha:
    timeout: 20000
    slow: 2000

module.exports = rc 'testium', getDefaults()
