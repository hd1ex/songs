srcfiles  := $(shell find songs/ -type f -name '*.tex')
destfiles := $(patsubst songs/%.tex,build/%.tex,$(srcfiles))

all: $(destfiles)

destination: $(destfiles)

build/%.tex: songs/%.tex
	@[ -d $$(dirname $@) ] || mkdir -p $$(dirname $@)
	@echo "Creating source: $@"
	@sed -e '/% SONG_FILE/r $<' template.tex > $@

clean:
	rm -rf build/

.PHONY: all clean destination