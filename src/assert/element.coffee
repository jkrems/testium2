assert = require 'assertive'

ElementMixin =
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
