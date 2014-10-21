default: build

setup:
	npm install

.PHONY: test
test: test-unit
# test-integration test-screenshot

test-integration: build
	@echo "# Integration Tests #"
	@./node_modules/.bin/coffee test/integration_runner.coffee
	@echo ""
	@echo ""

test-screenshot: build
	@echo "# Automatic Screenshot Tests #"
	@./node_modules/.bin/coffee test/screenshot_integration_runner.coffee
	@echo ""
	@echo ""

test-unit: build
	@echo "# Unit Tests #"
	@./node_modules/.bin/mocha test/unit
	@echo ""
	@echo ""

test-all: build
	@BROWSER=phantomjs,firefox,chrome make test-integration
	@make test-screenshot
	@make test-unit

build:
	@./node_modules/.bin/coffee -cbo lib src
	@./node_modules/.bin/npub prep src

prepublish:
	./node_modules/.bin/npub prep

clean:
	@rm -rf lib
	@rm -rf test/integration_log
	@rm -rf test/integration_screenshots
	@rm -rf test/screenshot_integration_log
	@rm -rf test/screenshot_integration_screenshots

# This will fail if there are unstaged changes in the checkout
test-checkout-clean:
	git diff --exit-code

all: setup clean test test-checkout-clean
