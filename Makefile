default: build

setup:
	npm install

.PHONY: test
test: test-unit test-screenshot test-integration

test-integration: build
	@echo "# Integration Tests #"
	@./node_modules/.bin/mocha test/integration
	@echo ""
	@echo ""

test-screenshot: build
	@echo "# Automatic Screenshot Tests #"
	@./node_modules/.bin/mocha test/screenshots.test.coffee
	@echo ""
	@echo ""

test-unit: build
	@echo "# Unit Tests #"
	@./node_modules/.bin/mocha test/unit
	@echo ""
	@echo ""

test-integration-all: build
	@testium_browser=phantomjs make test-integration
	@testium_browser=firefox make test-integration
	@testium_browser=chrome make test-integration

build:
	@./node_modules/.bin/coffee --no-header -cbo lib src
	@./node_modules/.bin/npub prep src

watch:
	@./node_modules/.bin/coffee --no-header -cwbo lib src

prepublish:
	./node_modules/.bin/npub prep

clean:
	@rm -rf lib
	@rm -rf test/integration_log

# This will fail if there are unstaged changes in the checkout
test-checkout-clean:
	git diff --exit-code

all: setup clean test test-checkout-clean
