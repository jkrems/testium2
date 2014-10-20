{find, reject} = require 'lodash'

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

CookieMixin =
  getStatusCode: ->
    cookies = @driver.getCookies()
    testiumCookie = getTestiumCookie(cookies)
    testiumCookie?.statusCode

  clearCookies: ->
    @driver.clearCookies()

module.exports = CookieMixin
