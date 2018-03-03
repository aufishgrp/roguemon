#!/usr/bin/env bash

goimports(){
	if [ -f goimports-out ]; then rm goimports-out; fi

	find . -name *.go \
		| grep -v .glide \
		| grep -v vendor \
		| grep -v easyjson.go \
		| xargs goimports -l \
		>> goimports-out 2>&1

	cat goimports-out && \
		if [ -n "`cat goimports-out`" ]; then \
			echo "Failure in goimports. Refer to goimports-out" \
			exit 1; \
		else \
			rm goimports-out; \
		fi
}

go_fmt(){
	if [ -f lint-out ]; then rm lint-out; fi

	go list ./... \
		| grep -v vendor \
		| xargs go fmt \
		>> lint-out 2>&1

	cat lint-out && \
		if [ -n "`cat lint-out`" ]; then \
			echo "Failure in go fmt. Refer to lint-out" \
			exit 1; \
		else \
			rm lint-out; \
		fi
}
go_vet(){
	find . -maxdepth 1 -type d \
		| egrep -v "\.[a-zA-Z]+$$|vendor|\.$$" \
		| xargs go tool vet -printfuncs="Info,Infof,Warning,Warningf,Error,Errorf"
}

go_lint(){
	if [ -f lint-out ]; then rm lint-out; fi
	
	find . -type d \
		| egrep -v "vendor|.glide" \
		| xargs -L 1 golint \
		| { egrep -v "be annoying to use|that stutters|_easyjson" || true; } \
		>> lint-out 2>&1
	
	cat lint-out && \
		if [ -n "`cat lint-out`" ]; then \
			echo "Failure in golint. Refer to lint-out"; \
			exit 1; \
		else \
			rm lint-out; \
		fi
}

goimports && go_fmt && go_vet && go_lint
