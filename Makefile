srcfiles  := $(shell find songs/ -type f -name '*.tex')
destfiles := $(patsubst songs/%.tex,build/%.tex,$(srcfiles))

all: $(destfiles)
	#echo "$(srcfiles)"
	#cat "$^" > all

destination: $(destfiles)

build/%.tex: songs/%.tex
	# Find directory
	# dir := $(shell substring ...)
	@[ -d pdfs ] || mkdir pdfs
	@echo "$< $@"

clean:
	rm -rf build/

.PHONY: all clean destination # clean