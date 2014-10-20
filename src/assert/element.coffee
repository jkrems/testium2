assert = require 'assertive'
{isString, isRegExp} = require 'lodash'

isTextOrRegexp = (textOrRegExp) ->
  isString(textOrRegExp) || isRegExp(textOrRegExp)

getProperty = (driver, selector, property) ->
  elements = driver.getElements selector
  count = elements.length

  throw new Error "Element not found for selector: #{selector}" if count is 0
  throw new Error """assertion needs a unique selector!
    #{selector} has #{count} hits in the page""" unless count is 1

  element = elements[0]
  [ element, element.get(property) ]

ElementMixin =
  elementHasText: (selector, textOrRegExp) ->
    if arguments.length is 3
      [doc, selector, textOrRegExp] = arguments
      assert.truthy 'elementHasText(docstring, selector, textOrRegExp) - requires docstring', isString doc
    else
      doc = "elementHasText: #{selector}"

    assert.truthy 'elementHasText(selector, textOrRegExp) - requires selector', isString selector
    assert.truthy 'elementHasText(selector, textOrRegExp) - requires textOrRegExp', isTextOrRegexp textOrRegExp

    [element, actualText] = getProperty(@driver, selector, 'text')

    if textOrRegExp == ''
      assert.equal textOrRegExp, actualText
    else
      assert.include doc, textOrRegExp, actualText

    element

  elementLacksText: (selector, textOrRegExp) ->
    if arguments.length is 3
      [doc, selector, textOrRegExp] = arguments
      assert.truthy 'elementLacksText(docstring, selector, textOrRegExp) - requires docstring', isString doc
    else
      doc = "elementLacksText: #{selector}"

    assert.truthy 'elementLacksText(selector, textOrRegExp) - requires selector', isString selector
    assert.truthy 'elementLacksText(selector, textOrRegExp) - requires textOrRegExp', isTextOrRegexp textOrRegExp

    [element, actualText] = getProperty(@driver, selector, 'text')

    assert.notInclude doc, textOrRegExp, actualText
    element

  elementHasValue: (selector, textOrRegExp) ->
    if arguments.length is 3
      [doc, selector, textOrRegExp] = arguments
      assert.truthy 'elementHasValue(docstring, selector, textOrRegExp) - requires docstring', isString doc
    else
      doc = "elementHasValue: #{selector}"

    assert.truthy 'elementHasValue(selector, textOrRegExp) - requires selector', isString selector
    assert.truthy 'elementHasValue(selector, textOrRegExp) - requires textOrRegExp', isTextOrRegexp textOrRegExp

    [element, actualValue] = getProperty(@driver, selector, 'value')

    if textOrRegExp == ''
      assert.equal textOrRegExp, actualValue
    else
      assert.include doc, textOrRegExp, actualValue

    element

  elementLacksValue: (selector, textOrRegExp) ->
    if arguments.length is 3
      [doc, selector, textOrRegExp] = arguments
      assert.truthy 'elementLacksValue(docstring, selector, textOrRegExp) - requires docstring', isString doc
    else
      doc = "elementLacksValue: #{selector}"

    assert.truthy 'elementLacksValue(selector, textOrRegExp) - requires selector', isString selector
    assert.truthy 'elementLacksValue(selector, textOrRegExp) - requires textOrRegExp', isTextOrRegexp textOrRegExp

    [element, actualValue] = getProperty(@driver, selector, 'value')

    assert.notInclude doc, textOrRegExp, actualValue
    element

  elementIsVisible: (selector) ->
    assert.hasType 'elementIsVisible(selector) - requires (String) selector', String, selector
    element = @browser.getElementWithoutError selector
    assert.truthy "Element not found for selector: #{selector}", element
    assert.truthy "Element should be visible for selector: #{selector}", element.isVisible()
    element

  elementNotVisible: (selector) ->
    assert.hasType 'elementNotVisible(selector) - requires (String) selector', String, selector
    element = @browser.getElementWithoutError selector
    assert.truthy "Element not found for selector: #{selector}", element
    assert.falsey "Element should not be visible for selector: #{selector}", element.isVisible()
    element

  elementExists: (selector) ->
    assert.hasType 'elementExists(selector) - requires (String) selector', String, selector
    element = @browser.getElementWithoutError selector
    assert.truthy "Element not found for selector: #{selector}", element
    element

  elementDoesntExist: (selector) ->
    assert.hasType 'elementDoesntExist(selector) - requires (String) selector', String, selector
    element = @browser.getElementWithoutError selector
    assert.falsey "Element found for selector: #{selector}", element

module.exports = ElementMixin
