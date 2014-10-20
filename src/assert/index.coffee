{extend} = require 'lodash'

class Assertions
  constructor: (@driver, @browser) ->

[
  require('./element')
].forEach (mixin) ->
  extend Assertions.prototype, mixin

module.exports = Assertions
