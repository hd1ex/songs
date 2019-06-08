srcfiles  := $(shell find songs/ -type f -name '*.tex')
destfiles := $(patsubst songs/%.tex,build/%.tex,$(srcfiles))
pdffiles := $(patsubst songs/%.tex,pdfs/%.pdf,$(srcfiles))

all: $(pdffiles)

pdfs/%.pdf: build/%.tex
	@[ -d $$(dirname $@) ] || mkdir -p $$(dirname $@)
	@echo "Creating pdf: $@"
	@pdflatex -synctex=1 -interaction=nonstopmode -file-line-error -aux-directory=$$(dirname $<) -output-directory=$$(dirname $<) "$<"
	@mv "$$(find $$(dirname $<) -name '*.pdf')" "$$(dirname $@)/"

build/%.tex: songs/%.tex
	@[ -d $$(dirname $@) ] || mkdir -p $$(dirname $@)
	@echo "Creating source: $@"
	@sed -e '/% SONG_FILE/r $<' template.tex > $@

clean:
	rm -rf build/
	rm -rf pdfs/

.PHONY: all clean destination