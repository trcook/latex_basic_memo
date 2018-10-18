
MD= $(wildcard *.md)

PDF=$(MD:.md=.pdf)


ifneq ("$(wildcard *.hincludes)","")
	HINCLUDES= --include-in-header $(wildcard *.hincludes)
endif

all: $(PDF)



%.tex: %.md config.yaml

	pandoc $< "config.yaml" -f markdown -t latex -o $@ -s --template "mymemo.latex"  $(HINCLUDES)


%.pdf: %.tex
	latexmk -f -gg -pdf -synctex=1 $<
	open $@



clean:
	echo done
	rm -rf *.toc  *.nav  *.snm *.log *.aux *.fdb_latexmk *.fls *.bbl *.blg *.run.xml *-blx.bib *.out *.synctex.gz skeleton.pdf



