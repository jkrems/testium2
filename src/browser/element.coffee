{truthy, hasType} = require 'assertive'
{partial} = require 'lodash'

STALE_MESSAGE = /stale element reference/

FIREFOX_MESSAGE = /Unable to locate element/
PHANTOMJS_MESSAGE = /Unable to find element/
CHROME_MESSAGE = /no such element/

visiblePredicate = (shouldBeVisible, element) ->
  return element?.isVisible() == shouldBeVisible

visibleFailure = (shouldBeVisible, selector, timeout) ->
  negate = if shouldBeVisible then '' else 'not '
  throw new Error "Timeout (#{timeout}ms) waiting for element (#{selector}) to #{negate}be visible."

elementExistsPredicate = (element) ->
  return element?

elementExistsFailure = (selector, timeout) ->
  throw new Error "Timeout (#{timeout}ms) waiting for element (#{selector}) to exist in page."

# Curry some functions for later use
isVisiblePredicate = partial visiblePredicate, true
isntVisiblePredicate = partial visiblePredicate, false

isVisibleFailure = partial visibleFailure, true
isntVisibleFailure = partial visibleFailure, false

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

  getElement: (selector) ->
    hasType 'getElement(selector) - requires (String) selector', String, selector

    @getElementWithoutError(selector)

  getElements: (selector) ->
    hasType 'getElements(selector) - requires (String) selector', String, selector

    @driver.getElements(selector)

  waitForElement: (selector, timeout) ->
    deprecate 'waitForElement', 'waitForElementVisible'
    hasType 'getElements(selector) - requires (String) selector', String, selector
    @_waitForElement(selector, isVisiblePredicate, isVisibleFailure, timeout)

  waitForElementVisible: (selector, timeout) ->
    hasType 'getElements(selector) - requires (String) selector', String, selector
    @_waitForElement(selector, isVisiblePredicate, isVisibleFailure, timeout)

  waitForElementNotVisible: (selector, timeout) ->
    hasType 'getElements(selector) - requires (String) selector', String, selector
    @_waitForElement(selector, isntVisiblePredicate, isntVisibleFailure, timeout)

  waitForElementExist: (selector, timeout) ->
    hasType 'getElements(selector) - requires (String) selector', String, selector
    @_waitForElement(selector, elementExistsPredicate, elementExistsFailure, timeout)

  click: (selector) ->
    hasType 'click(selector) - requires (String) selector', String, selector

    element = @driver.getElement(selector)
    truthy "Element not found at selector: #{selector}", element
    element.click()

  # Where predicate takes a single parameter which is an element (or null) and
  # returns true when the wait is over
  _waitForElement: (selector, predicate, failure, timeout=3000) ->
    start = Date.now()
    @driver.setElementTimeout(timeout)

    foundElement = null
    while (Date.now() - start) < timeout
      element = @getElementWithoutError(selector)

      try
        predicateResult = predicate element
      catch exception
        # Occasionally webdriver throws an error about the element reference being
        # stale.  Let's handle that case as the element doesn't yet exist. All
        # other errors are re thrown.
        message = exception.toString()
        throw exception if not STALE_MESSAGE.test(message)

      if predicateResult
        foundElement = element
        break

    @driver.setElementTimeout(0)

    failure(selector, timeout) if foundElement == null

    foundElement

module.exports = ElementMixin
