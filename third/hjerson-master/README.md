Hjerson: A tool for automatic error classification
===

By: Maja Popovic <maja.popovic@dfki.de>,  August 2011



Hjerson detects translation errors using WER alignment and RPER
(reference PER) and HPER (hypotheses PER) errors.
It is written in Python, so you have to install Python 2 or Python 3.

The following five error classes are supported:

- inflectional (morphological) errors, i.e. incorrect word forms
- reordering errors, i.e. incorrect word order
- missing words
- extra words
- lexical errors, i.e. incorrect lexical choice

The option -h, --help outputs a description of the available command
line options.



The required inputs are:
- translation reference and hypothesis
- base forms of translation reference and hypothesis

If any additional information at the word level is available (such as
POS tags), it is possible to incorporate it as well in order to obtain
more detals.

The required format of all inputs is tokenised (and preferably
true-cased) raw text containing one sentence per line.

In the case of multiple references, all available reference
sentences must be separated by the symbol #.



The default output are overall (document level) raw error counts and
error rates (counts normalised over the reference or hypothesis length) 
for each of the five error classes.

Optional outputs are:

    -s, --sent  sentence-errors.txt
        raw error counts and error rates at the sentence level are written
        in "sentence-errors.txt"

    -c, --cats  categories.txt
        Original reference and hypothesis words labelled with a
        corresponding error class are written in "categories.txt"

    -m, --html  categories.html
        Original reference and hypothesis words with coloured errors in
        HTML format.

If the additional information is used, only "categories.txt" and
"categories.html" will be different.


Example for testing:
---

You can try the tool on the given example using example.ref and
example.ref.base as reference inputs along with example.hyp and
example.hyp.base as hypothesis inputs.

If you want to try additional information, you can use reference and
hypothesis POS tags example.ref.pos and example.hyp.pos.

Then you can compare obtained files with example.totalerrorrates,
example.senterrorrates, example.(pos.)cats and example.(pos.)html.

Attribution
---

    Publications of results obtained through the use of original or
    modified versions of the software have to cite the authors by referring
    to the following publication:

    Maja Popović: "Hjerson: An Open Source Tool for Automatic Error
    Classification of Machine Translation Output". The Prague Bulletin of
    Mathematical Linguistics No. 96, pp. 59--68, October 2011


