# For Russian, the number of tokens in files *tok and *tok.base did not match initially. This was due to the fact that the stemmer used leaves blank sometimes acronyms made up of latin characters. The same applies to *tok.true and *tok.true.base files too.
# As the bug affects just a handful of lines, they have been fixed manually following the procedure below

function ru_stem_fix {
	# find out lines with different number of words (those are the problematic ones)
	diff <(awk '$0=NR" "NF' references/newstest2016-ruen-src.ru.tok) <(awk '$0=NR" "NF' references/newstest2016-ruen-src.ru.tok.base)
	# 2692 20 18
	# "ERA" missing in stemmed file!
	#	Против Норриса ( 2-2 , ERA 4,43 ) будет играть питчер-правша Эрвин Сантана ( 5-4 , ERA 4,73 ) 
	#	прот норрис ( 2-2 ,  4,43 ) будет игра питчер-правш эрвин санта ( 5-4 ,  4,73 ) .

	diff <(awk '$0=NR" "NF' references/newstest2016-enru-ref.ru.tok.true) <(awk '$0=NR" "NF' references/newstest2016-enru-ref.ru.tok.true.base)

	diff <(awk '$0=NR" "NF' systems/enru-nmt1.tok) <(awk '$0=NR" "NF' systems/enru-nmt1.tok.base)
	#< 1506 19 18
	#< 1515 24 23
	#< 1518 16 15
	diff <(awk '$0=NR" "NF' systems/enru-smt1.tok) <(awk '$0=NR" "NF' systems/enru-smt1.tok.base)
	#< 1515 23 22
	#< 1518 18 17
	#< 2692 20 18

	diff <(awk '$0=NR" "NF' systems/enru-nmt1.tok.true) <(awk '$0=NR" "NF' systems/enru-nmt1.tok.true.base)
	diff <(awk '$0=NR" "NF' systems/enru-smt1.tok.true) <(awk '$0=NR" "NF' systems/enru-smt1.tok.true.base)
}
