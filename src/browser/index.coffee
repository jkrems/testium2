{extend} = require 'lodash'

Assertions = require '../assert'

class Browser
  constructor: (@driver, @proxyUrl, @commandUrl) ->
    @assert = new Assertions @driver, this

[
  require('./cookie')
  require('./element')
  require('./navigation')
].forEach (mixin) ->
  extend Browser.prototype, mixin

module.exports = Browser
