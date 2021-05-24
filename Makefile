idris2 = idris2
node = node

init: FORCE
	test -d db    || mkdir db
	test -d build || mkdir build
	touch service/order-taking-service.js

build: src order-taking-service.ipkg FORCE
	$(idris2) --typecheck order-taking-service.ipkg --codegen node

FORCE:

watch:
	while inotifywait -e close_write -r src; do $(idris2) --typecheck order-taking-service.ipkg; done

clean-lsp-log:
	rm ~/.cache/nvim/lsp.log

clean-db:
	rm -r db

clean:
	$(idris2) --clean order-taking-service.ipkg
	rm -r build

repl:
	rlwrap $(idris2) --repl order-taking-service.ipkg --codegen node

nodejs:
	$(idris2) --clean order-taking-service.ipkg
	$(idris2) --build order-taking-service.ipkg --codegen node

start: init clean nodejs
	rm service/order-taking-service.js
	cp build/exec/order-taking-service service/order-taking-service.js
	$(node) service/order-taking-service.js

start-opt: init clean nodejs
	rm service/order-taking-service.js
	cp build/exec/order-taking-service service/order-taking-service.js
	npx google-closure-compiler service/order-taking-service.js \
			--language_out=ES_2020 \
			--isolation_mode=IIFE --module_resolution=NODE \
			--assume_function_wrapper > service/order-taking-service-opt.js
	$(node) service/order-taking-service-opt.js

restart:
	$(node) service/order-taking-service.js

restart-opt:
	$(node) service/order-taking-service-opt.js

