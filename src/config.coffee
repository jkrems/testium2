rc = require 'rc'

getDefaults = ->
  browser: 'phantomjs'
  appDirectory: process.cwd()
  appPort: process.env.PORT || 41998
  launch: false
  launchTimeout: 30000
  mocha:
    timeout: 20000
    slow: 2000

module.exports = rc 'testium', getDefaults()
