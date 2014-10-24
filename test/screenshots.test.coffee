fs = require 'fs'
{execFile} = require 'child_process'

assert = require 'assertive'
rimraf = require 'rimraf'

SCREENSHOT_DIRECTORY = "#{__dirname}/integration_log/screenshots"
TEST_FILE = 'test/screenshot_integration/force_screenshot.hidden.coffee'

describe 'screenshots', ->
  before "rm -rf #{SCREENSHOT_DIRECTORY}", (done) ->
    rimraf SCREENSHOT_DIRECTORY, done

  before 'run failing test suite', (done) ->
    @timeout 10000
    mocha = execFile 'mocha', [ TEST_FILE ], (err, stdout, stderr) ->
      try
        assert.equal 2, mocha.exitCode
        done()
      catch err
        console.log stdout
        console.log stderr
        done err

  before "readdir #{SCREENSHOT_DIRECTORY}", ->
    @files = fs.readdirSync SCREENSHOT_DIRECTORY
    @files.sort()

  it 'creates two screenshots', ->
    assert.deepEqual [
      'forced_screenshot_my_test.png',
      'forced_screenshot_some_sPecial_chars.png'
    ], @files
