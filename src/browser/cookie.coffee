{find, reject} = require 'lodash'
{hasType} = require 'assertive'

{tryParse} = require './json'

decode = (value) ->
  (new Buffer value, 'base64').toString('utf8')

parseTestiumCookie = (cookie) ->
  value = decode(cookie.value)
  tryParse(value)

getTestiumCookie = (cookies) ->
  testiumCookie = find cookies, name: '_testium_'

  unless testiumCookie?
    throw new Error 'Unable to communicate with internal proxy. Make sure you are using relative paths.'

  parseTestiumCookie(testiumCookie)

removeTestiumCookie = (cookies) ->
  reject cookies, name: '_testium_'

validateCookie = (invocation, cookie) ->
  hasType "#{invocation} - cookie must be an object", Object, cookie
  if !cookie.name
    throw new Error "#{invocation} - cookie must contain `name`"
  if !cookie.value
    throw new Error "#{invocation} - cookie must contain `value`"

CookieMixin =
  setCookie: (cookie) ->
    validateCookie 'setCookie(cookie)', cookie

    @driver.setCookie(cookie)

  setCookies: (cookies) ->
    for cookie in cookies
      @setCookie(cookie)
    this

  getCookie: (name) ->
    hasType 'getCookie(name) - requires (String) name', String, name

    cookies = @driver.getCookies()
    find cookies, {name}

  getCookies: ->
    removeTestiumCookie driver.getCookies()

  clearCookies: ->
    @driver.clearCookies()

  # BEGIN _testium_ cookie magic
  
  _getTestiumCookieField: (name) ->
    cookies = @driver.getCookies()
    testiumCookie = getTestiumCookie(cookies)
    testiumCookie?[name]

  getStatusCode: ->
    @_getTestiumCookieField 'statusCode'

  getHeaders: ->
    @_getTestiumCookieField 'headers'

  getHeader: (name) ->
    hasType 'getHeader(name) - require (String) name', String, name
    @getHeaders()[name]

  # END _testium_ cookie magic

module.exports = CookieMixin
