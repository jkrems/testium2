{parse: urlParse} = require 'url'

waitFor = require './wait'

NavigationMixin =
  navigateTo: (url, options) ->
    options ?= {}
    options.url = url

    hasProtocol = /^[^:\/?#]+:\/\//
    unless hasProtocol.test url
      url = "#{@proxyUrl}#{url}"

    @driver.http.post "#{@commandUrl}/new-page", options

    # WebDriver does nothing if currentUrl is the same as targetUrl
    currentUrl = @driver.getUrl()
    if currentUrl == url
      @driver.refresh()
    else
      @driver.navigateTo(url)

    # Save the window handle for referencing later
    # in `switchToDefaultWindow`
    @driver.rootWindow = @driver.getCurrentWindowHandle()

  refresh: ->
    @driver.refresh()

  getUrl: ->
    @driver.getUrl()

  getPath: ->
    url = @driver.getUrl()
    urlParse(url).path

  waitForUrl: (url, query, timeout) ->
    if typeof query is 'number'
      timeout = query
    else if isObject query
      url = makeUrlRegExp url, query
    waitFor(url, 'Url', (=> @driver.getUrl()), timeout ? 5000)

  waitForPath: (url, timeout=5000) ->
    waitFor(url, 'Path', (=> @getPath()), timeout)

module.exports = NavigationMixin
