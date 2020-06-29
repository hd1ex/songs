srcfiles  := $(shell sh get_added_song_order.sh | cut -f 2 -d " ")
destfiles := $(patsubst songs/%.tex,build/%.tex,$(srcfiles))
pdffiles := $(patsubst songs/%.tex,pdfs/%.pdf,$(srcfiles))
latex := pdflatex -synctex=1 -interaction=nonstopmode -file-line-error

all: songbook songs
songbook: pdfs/songbook.pdf
songs: $(pdffiles)

pdfs/%.pdf: build/%.tex
	@[ -d $$(dirname $@) ] || mkdir -p $$(dirname $@)
	TEXFILE="$<"; \
	ln -sf "../../$@" "$${TEXFILE%.*}.pdf"
	# Creating pdf: $@
	$(latex) -output-directory=$$(dirname $<) "$<"

build/%.tex: songs/%.tex template.tex
	# Let LaTeX put its build files into the build dir
	@[ -d $$(dirname $@) ] || mkdir -p $$(dirname $@)
	SONGDIR="build/songs/$$(echo "$$(dirname $@)" | cut -d'/' -f2-)"; \
	[ -d "$$SONGDIR" ] || mkdir -p "$$SONGDIR"
	ln -sf "../songs" "$$(dirname $@)/songs"

	# Prepare a songbook that includes the single song
	cp template.tex $@
	# Remove the title and index pages
	sed -ie '/\\maketitle/d' $@
	sed -ie '/\\showindex/d' $@
	# Insert an include statement for the song
	sed -ie "/% SONG_FILE/a \\\\\\\\include{$$(echo $< | cut -f 1 -d '.')}" $@
	# Set the apropiate song number
	SONG_NUM=$$(echo '$(destfiles)' | sed 's/ /\n/g' \
	| sed '1!G;h;$$!d' | grep -n '$@' | cut -f1 -d:) ; \
	sed -ie "/% SONG_FILE/a \\\\\\\\setcounter{songnum}{$$SONG_NUM}" $@

pdfs/songbook.pdf: build/songbook.tex
	@[ -d $$(dirname $@) ] || mkdir $$(dirname $@)
	ln -sf "../pdfs/songbook.pdf" "build/songbook.pdf"
	# Making songbook...
	$(latex) -output-directory=$$(dirname $<) "$<"
	for index in $$(find build/ -iname '*.sxd'); do \
		texlua songidx.lua $$index "$$(echo "$$index" | cut -d '.' -f1).sbx" ; \
	done
	$(latex) -output-directory=$$(dirname $<) "$<"

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

.PHONY: clean all songbook songs
.SECONDARY:
