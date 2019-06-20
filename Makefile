srcfiles  := $(shell find songs/ -type f -name '*.tex')
destfiles := $(patsubst songs/%.tex,build/%.tex,$(srcfiles))
pdffiles := $(patsubst songs/%.tex,pdfs/%.pdf,$(srcfiles))

all: $(pdffiles)

pdfs/%.pdf: build/%.tex
	@[ -d $$(dirname $@) ] || mkdir -p $$(dirname $@)
	@echo "Creating pdf: $@"
	pdflatex -synctex=1 -interaction=nonstopmode -file-line-error -output-directory=$$(dirname $<) "$<"
	mv "$$(find $$(dirname $<) -name '*.pdf')" "$$(dirname $@)/"

build/%.tex: songs/%.tex template.tex
	@[ -d $$(dirname $@) ] || mkdir -p $$(dirname $@)
	@echo "Creating source: $@"
	@sed -e '/% SONG_FILE/r $<' template.tex > $@

songbook: pdfs/songbook.pdf

pdfs/songbook.pdf: build/songbook.tex
	@[ -d $$(dirname $@) ] || mkdir $$(dirname $@)
	@echo "Making songbook..."
	latexmk -pdf -output-directory=$$(dirname $<) "$<"
	mv "build/songbook.pdf" "$@"

build/songbook.tex: $(srcfiles) template.tex
	[ -d build/ ] || mkdir build/
	cp template.tex build/songbook.tex
	find songs -type d -exec mkdir -p build/{} \;
	for filename in $(srcfiles); do \
		sed -ie "/% SONG_FILE/a \\\\\\\\include{$$(echo $$filename | cut -f 1 -d '.')}" $@ ; \
	done

clean:
	rm -rf build/
	rm -rf pdfs/

.PHONY: clean all songbook
.SECONDARY:
