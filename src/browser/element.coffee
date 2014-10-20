

FIREFOX_MESSAGE = /Unable to locate element/
PHANTOMJS_MESSAGE = /Unable to find element/
CHROME_MESSAGE = /no such element/

ElementMixin =
  getElementWithoutError: (selector) ->
    try
      @driver.getElement(selector)
    catch exception
      message = exception.toString()

      return null if FIREFOX_MESSAGE.test(message)
      return null if PHANTOMJS_MESSAGE.test(message)
      return null if CHROME_MESSAGE.test(message)

      throw exception

module.exports = ElementMixin
