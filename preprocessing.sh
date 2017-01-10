#!/bin/bash

# Data preprocessing
#	- desgmise
#	- train monolingual data
#	- train parallel data
#	- reference translations and MT outputs


# removes SGM markup
function desgmise {
	INPUT=$1
	echo "desgm $INPUT"
	cat $INPUT | \
		perl -ne 'print $1."\n" if /<seg[^>]+>\s*(.*)\s*<.seg>/i;' \
		> "${INPUT%.*}"
}

# convert systems' outputs to plain text
function desgmises_systems {
	for i in systems/*.sgm; do
		desgmise $i
	done
}

# convert reference translations to plain text
function desgmises_references {
	for i in references/*.sgm; do
		desgmise $i
	done
}


# pre-processes monolingual data (will be used to build language models)
# tokenisation and true-casing
# NOTE: the data needs to be downloaded first with data_train_mono/get_data_train_mono.sh
function preprocess_train_mono {
	echo "----- preprocess train mono -----"


	echo "  en"
	zcat data_train_mono/news.2015.en.shuffled.gz | python code/tokenizer.py english \
	> data_train_mono/news.2015.en.shuffled.tok

	perl third/moses/recaser/train-truecaser.perl --model data_train_mono/truecasemodel.en --corpus data_train_mono/news.2015.en.shuffled.tok

	cat data_train_mono/news.2015.en.shuffled.tok | perl third/moses/recaser/truecase.perl --model data_train_mono/truecasemodel.en \
	| gzip > data_train_mono/news.2015.en.shuffled.tok.true.gz




	echo "  cs"
	zcat data_train_mono/news.2015.cs.shuffled.gz | python code/tokenizer.py czech \
	> data_train_mono/news.2015.cs.shuffled.tok

	perl third/moses/recaser/train-truecaser.perl --model data_train_mono/truecasemodel.cs --corpus data_train_mono/news.2015.cs.shuffled.tok

	cat data_train_mono/news.2015.cs.shuffled.tok | perl third/moses/recaser/truecase.perl --model data_train_mono/truecasemodel.cs \
	| gzip > data_train_mono/news.2015.cs.shuffled.tok.true.gz




	echo "  de"
	zcat data_train_mono/news.2015.de.shuffled.gz | python code/tokenizer.py german \
	> data_train_mono/news.2015.de.shuffled.tok

	perl third/moses/recaser/train-truecaser.perl --model data_train_mono/truecasemodel.de --corpus data_train_mono/news.2015.de.shuffled.tok

	cat data_train_mono/news.2015.de.shuffled.tok | perl third/moses/recaser/truecase.perl --model data_train_mono/truecasemodel.de \
	| gzip > data_train_mono/news.2015.de.shuffled.tok.true.gz




	echo "  fi"
	zcat data_train_mono/news.2015.fi.shuffled.gz | python code/tokenizer.py finnish \
	> data_train_mono/news.2015.fi.shuffled.tok

	perl third/moses/recaser/train-truecaser.perl --model data_train_mono/truecasemodel.fi --corpus data_train_mono/news.2015.fi.shuffled.tok

	cat data_train_mono/news.2015.fi.shuffled.tok | perl third/moses/recaser/truecase.perl --model data_train_mono/truecasemodel.fi \
	| gzip > data_train_mono/news.2015.fi.shuffled.tok.true.gz




	echo "  ro"
	zcat data_train_mono/news.2015.ro.shuffled.gz | perl third/moses/tokenizer/tokenizer.perl -l ro \
	> data_train_mono/news.2015.ro.shuffled.tok

	perl third/moses/recaser/train-truecaser.perl --model data_train_mono/truecasemodel.ro --corpus data_train_mono/news.2015.ro.shuffled.tok

	cat data_train_mono/news.2015.ro.shuffled.tok | perl third/moses/recaser/truecase.perl --model data_train_mono/truecasemodel.ro \
	| gzip > data_train_mono/news.2015.ro.shuffled.tok.true.gz




	echo "  ru"
	zcat data_train_mono/news.2015.ru.shuffled.gz | perl third/moses/tokenizer/tokenizer.perl -l ru \
	> data_train_mono/news.2015.ru.shuffled.tok

	perl third/moses/recaser/train-truecaser.perl --model data_train_mono/truecasemodel.ru --corpus data_train_mono/news.2015.ru.shuffled.tok

	cat data_train_mono/news.2015.ru.shuffled.tok | perl third/moses/recaser/truecase.perl --model data_train_mono/truecasemodel.ru \
	| gzip > data_train_mono/news.2015.ru.shuffled.tok.true.gz
}





# pre-processes parallel data (will be used to build TODO)
# tokenisation and true-casing
# NOTE: the data needs to be downloaded first with data_train_parallel/get_data_train_parallel.sh
function preprocess_train_parallel {
	echo "----- preprocess train parallel -----"

	DATADIR=data_train_parallel
	# NOTE some input files need to be passed through: fromdos and perl -p -i -e "s/\r//g" news-commentary-v11.de-en.?? and sed -i.old $'s/\xE2\x80\xA8/ /g' inFile


	echo "  deen, de"
	cat $DATADIR/news-commentary-v11.de-en.de | head -n 100000 | python code/tokenizer.py german \
	| perl third/moses/recaser/truecase.perl --model data_train_mono/truecasemodel.de \
	> $DATADIR/news-commentary-v11.tok.true.de-en.de

	echo "  deen, en"
	cat $DATADIR/news-commentary-v11.de-en.en | head -n 100000 | python code/tokenizer.py english \
	| perl third/moses/recaser/truecase.perl --model data_train_mono/truecasemodel.en \
	> $DATADIR/news-commentary-v11.tok.true.de-en.en



	echo "  fien, fi"
	cat $DATADIR/europarl-v8.fi-en.fi | head -n 100000 | python code/tokenizer.py finnish \
	| perl third/moses/recaser/truecase.perl --model data_train_mono/truecasemodel.fi \
	> $DATADIR/europarl-v8.tok.true.fi-en.fi

	echo "  fien, en"
	cat $DATADIR/europarl-v8.fi-en.en | head -n 100000 | python code/tokenizer.py english \
	| perl third/moses/recaser/truecase.perl --model data_train_mono/truecasemodel.en \
	> $DATADIR/europarl-v8.tok.true.fi-en.en



	echo "  roen, ro"
	cat $DATADIR/europarl-v8.ro-en.ro | head -n 100000 \
	| perl third/moses/tokenizer/tokenizer.perl -l ro \
	| perl third/moses/recaser/truecase.perl --model data_train_mono/truecasemodel.ro \
	> $DATADIR/europarl-v8.tok.true.ro-en.ro

	echo "  roen, en"
	cat $DATADIR/europarl-v8.ro-en.en | head -n 100000 | python code/tokenizer.py english \
	| perl third/moses/recaser/truecase.perl --model data_train_mono/truecasemodel.en \
	> $DATADIR/europarl-v8.tok.true.ro-en.en


	echo "  ruen, ru"
	perl -p -i -e "s/\r//g" data_train_parallel/news-commentary-v11.ru-en.??
	sed -i.old $'s/\xE2\x80\xA8/ /g' data_train_parallel/news-commentary-v11.ru-en.en
	cat $DATADIR/news-commentary-v11.ru-en.ru | head -n 100000 \
	| perl third/moses/tokenizer/tokenizer.perl -l ru \
	| perl third/moses/recaser/truecase.perl --model data_train_mono/truecasemodel.ru \
	> $DATADIR/news-commentary-v11.tok.true.ru-en.ru

	echo "  ruen, en"
	cat $DATADIR/news-commentary-v11.ru-en.en | head -n 100000 | python code/tokenizer.py english \
	| perl third/moses/recaser/truecase.perl --model data_train_mono/truecasemodel.en \
	> $DATADIR/news-commentary-v11.tok.true.ru-en.en
}



# pre-processes reference translatoins and systems (i.e. MT outputs)
# tokenisation, true-casing and stemming (for Hjerson)
# NOTE: systems used... TODO

# All languages use NLTK tokenizer+stemmer, except:
# - Czech: stemmer http://research.variancia.com/czech_stemmer/
# - Romanian: tokenizer Moses v3
# - Russian: tokenizer Moses v3
function preprocess_test {
	echo "----- preprocess test -----"


	for i in references/*cs systems/encs-?mt?; do
		echo "Preprocessing (tokenise + truecase + stem) $i"
		cat $i | python code/tokenizer.py czech > $i.tok

		cat $i.tok | perl third/moses/recaser/truecase.perl \
		--model data_train_mono/truecasemodel.cs \
		> $i.tok.true

		cat $i.tok.true | python3 third/czech_stemmer_rev0/czech_stemmer.py light > $i.tok.true.base-light 2> $i.tok.true.base-light.log
		cat $i.tok.true | python3 third/czech_stemmer_rev0/czech_stemmer.py aggressive > $i.tok.true.base-aggressive 2> $i.tok.true.base-aggressive.log
	done

	for i in references/*de systems/ende-?mt?; do
		echo "Preprocessing (tokenise + truecase + stem) $i"
		cat $i | python code/tokenizer.py german > $i.tok
		cat $i.tok | python code/stemmer.py german > $i.tok.base
		cat $i.tok | perl third/moses/recaser/truecase.perl \
		--model data_train_mono/truecasemodel.de \
		> $i.tok.true
		cat $i.tok.true | python code/stemmer.py german > $i.tok.true.base
	done

	for i in references/*fi systems/enfi-?mt?; do
		echo "Preprocessing (tokenise + truecase + stem) $i"
		cat $i | python code/tokenizer.py finnish > $i.tok
		cat $i.tok | python code/stemmer.py finnish > $i.tok.base
		cat $i.tok | perl third/moses/recaser/truecase.perl \
		--model data_train_mono/truecasemodel.fi \
		> $i.tok.true
		cat $i.tok.true | python code/stemmer.py finnish > $i.tok.true.base
	done

	# Romanian, Russian not in punkt, so we cannot use NLTK tokenizer!
	for i in references/*ro systems/enro-?mt?; do
		echo "Preprocessing (tokenise + truecase + stem) $i"
		cat $i | perl third/moses/tokenizer/tokenizer.perl -l ro > $i.tok
		cat $i.tok | python code/stemmer.py romanian > $i.tok.base
		cat $i.tok | perl third/moses/recaser/truecase.perl \
		--model data_train_mono/truecasemodel.ro \
		> $i.tok.true
		cat $i.tok.true | python code/stemmer.py romanian > $i.tok.true.base
	done

	for i in references/*ru systems/enru-?mt?; do
		echo "Preprocessing (tokenise + truecase + stem) $i"
		cat $i | perl third/moses/tokenizer/tokenizer.perl -l ru > $i.tok
		cat $i.tok | python code/stemmer.py russian > $i.tok.base
		cat $i.tok | perl third/moses/recaser/truecase.perl \
		--model data_train_mono/truecasemodel.ru \
		> $i.tok.true
		cat $i.tok.true | python code/stemmer.py russian > $i.tok.true.base
	done


	for i in references/*en systems/??en-?mt?; do
		echo "Preprocessing (tokenise + truecase + stem) $i"
		cat $i | python code/tokenizer.py english > $i.tok
		cat $i.tok | python code/stemmer.py english > $i.tok.base
		cat $i.tok | perl third/moses/recaser/truecase.perl \
		--model data_train_mono/truecasemodel.en \
		> $i.tok.true
		cat $i.tok.true | python code/stemmer.py english > $i.tok.true.base
	done
}





# ----------- desgmise
desgmises_systems
desgmises_references

# ----------- data preprocessing
preprocess_train_mono
preprocess_train_parallel # run after preprocess_train_mono as it needs truecase models built there
preprocess_test # run after preprocess_train_mono as it needs truecase models built there

