COFFEE_PATH="`pwd`/node_modules/coffee-script/bin/coffee"

all: build

build:
	$(COFFEE_PATH) --compile --output lib/ src/lib/
	$(COFFEE_PATH) --compile --output . src/index.coffee

clean:
	rm -rf lib

.PHONY: build clean
