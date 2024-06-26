#!/bin/bash

lint_go_snippets() {
	local markdown_file="$1"

	mkdir -p tmp
	awk '/^```go$/ {p=1}; p; /^```$/ {p=0;print"--- --- ---"}' "$markdown_file" |
		grep -vE '^```(go)?$' |
		csplit \
		-z -s - '/--- --- ---/' \
		'{*}' \
		--suppress-matched \
		-f tmp/readme_snippet_ -b '%02d.go'

	for snippet in ./tmp/readme_snippet_*.go; do
		echo "building $snippet ..."
		go build -v -o tmp/tmp "$snippet" || exit 1
	done

	for snippet in ./tmp/readme_snippet_*.go; do
		echo "checking format $snippet ..."
		if ! diff -u <(echo -n) <(gofmt -d "$snippet"); then
			exit 1
		fi
	done
}

if [ "$1" = "" ]
then
	echo "usage: lintdown.sh FILENAME"
	exit 1
fi

file="$1"
if [ ! -f "$file" ]
then
	echo "error file not found '$file'"
	exit 1
fi

lint_go_snippets "$file"

