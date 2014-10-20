{extend} = require 'lodash'
{truthy, hasType} = require 'assertive'

Assertions = require '../assert'

class Browser
  constructor: (@driver, @proxyUrl, @commandUrl) ->
    @assert = new Assertions @driver, this

  close: (callback) ->
    hasType 'close(callback) - requires (Function) callback', Function, callback

    @driver.close()
    callback()

  evaluate: (clientFunction) ->
    if arguments.length > 1
      [args..., clientFunction] = arguments

    invocation = 'evaluate(clientFunction) - requires (Function|String) clientFunction'
    truthy invocation, clientFunction
    if typeof clientFunction == 'function'
      args = JSON.stringify(args ? [])
      clientFunction = "return (#{clientFunction}).apply(this, #{args});"
    else if typeof clientFunction != 'string'
      throw new Error invocation

    @driver.evaluate(clientFunction)

[
  require('./cookie')
  require('./element')
  require('./navigation')
  require('./page')
].forEach (mixin) ->
  extend Browser.prototype, mixin

module.exports = Browser
