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

module.exports = NavigationMixin
