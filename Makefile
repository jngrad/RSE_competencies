.DEFAULT_GOAL := all

MAKE_PDFA := true

objects := intro.pdf competencies.pdf institutionalised_education.pdf survey.pdf call_to_action.pdf

all: $(objects)

%.pdf: %.md bibliography.bib contributors.yml preamble.sty build/template.tex filter.py
	@mkdir -p build
	@rm -f build/pdfa.xmpi
	cp --update preamble.sty build/
	cp --update bibliography.bib build/
	python3 filter.py --input="${<}" --output="build/${<}" --contributors="contributors.yml"
	pandoc \
	    --standalone \
	    --number-sections \
	    --filter pandoc-xnos \
	    --bibliography=bibliography.bib \
	    --biblatex \
	    --toc \
	    --template="build/template.tex" \
	    -M pdfa-$(MAKE_PDFA)=1 \
	    -M date="`date "+%B %e, %Y"`" \
	    -M datexmp="`date "+%F"`" \
	    -V hyperrefoptions=pdfa \
	    -V colorlinks=true \
	    -V papersize=a4 \
	    -o "build/${@:.pdf=}.tex" \
	    "build/$<"
	@sed -i '/\\author{}/d' "build/${@:.pdf=}.tex"
	latexmk \
	    -pdflatex -bibtex -halt-on-error \
	    -jobname="${@:.pdf=}" -cd "build/${@:.pdf=}.tex"
	@mv "build/${@}" "${@}"

build/template.tex: template.py
	@mkdir -p build
	pandoc --print-default-template=latex > "${@}"
	python3 "${<}" "${@}"

clean:
	rm -f $(objects)
