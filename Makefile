# Command line paths
ESLINT = ./node_modules/eslint/bin/eslint.js
MOCHA = ./node_modules/mocha/bin/_mocha
ROLLUP = ./node_modules/.bin/rollup
COVERALLS = ./node_modules/coveralls/bin/coveralls.js
ISTANBUL  = ./node_modules/istanbul/lib/cli.js
JISON = ./node_modules/.bin/jison

# folders
DIST = ./dist/
SRC = ./src/

build:
	@ mkdir -p $(DIST)
	@ rm -rf $(SRC)/grammar/index.*
	@ touch $(SRC)grammar/index.jison
	@ cat $(SRC)grammar/grammar.jison >> $(SRC)grammar/index.jison
	@ cat $(SRC)grammar/helpers.js >> $(SRC)grammar/index.jison
	@ cat $(SRC)grammar/ast.js >> $(SRC)grammar/index.jison
	@ $(JISON) $(SRC)grammar/index.jison -m js -o $(SRC)grammar
	@ echo "export default index;" >> $(SRC)grammar/index.js
	@ $(ROLLUP) $(SRC)index.js -c -f umd > $(DIST)index.js
	@ $(ROLLUP) $(SRC)index.js -c -f es > $(DIST)index.next.js

clean:
	@ rm -rf $(DIST)

test:
	@ make build
	@ $(ISTANBUL) cover $(MOCHA) -- test/index.js

lint:
	@ $(ESLINT) src test

send-coverage:
	@ RIOT_COV=1 cat ./coverage/lcov.info | $(COVERALLS)
	ifeq ($(TESTCOVER),master 4.2)
		@ npm install codeclimate-test-reporter
		@ codeclimate-test-reporter < coverage/lcov.info
	endif

.PHONY: build clean test lint send-coverage