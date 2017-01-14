#!/bin/bash

MBLEU="perl third/moses/generic/multi-bleu.perl"
CHRF="python third/chrF.py"
HJERSON="python third/hjerson-master/hjerson.py"


# Output similarity (Section 3)
function overlap_metric {
	LP=$1
	METRIC=$2

	echo "------------ overlaps ($METRIC) $LP ------------"

	SYSTEMSPRINT="-"
	for i in systems/$LP*[0-9]; do
		iprint=$(basename $i | cut -f2 -d"_" | cut -f1 -d".")
		SYSTEMSPRINT="$SYSTEMSPRINT	$iprint"
	done
	echo -e $SYSTEMSPRINT


	for i in systems/$LP*[0-9]; do
		iprint=$(basename $i | cut -f2 -d"_" | cut -f1 -d".")
		TOPRINT="$iprint	"
		for j in systems/$LP*[0-9]; do
			if [ ! "$i" == "$j" ]; then
				if [ $METRIC == "BLEU" ]; then
					SCORE=$($MBLEU $i < $j | cut -f1 -d"," | cut -f3 -d" ")
				else
					SCORE=$($CHRF -b 1 -R $i -H $j | cut -f 2)
				fi
				TOPRINT="$TOPRINT	$SCORE"
			else
				TOPRINT="$TOPRINT	-"
			fi
		done
		echo -e $TOPRINT
	done
}


#Fluency (Section 4)
function fluency {

THEANOLM="$HOME/.local/bin/theanolm"

for MYLANG in "en" "cs" "de" "fi" "ro" "ru" ; do
	if [ ! -f "./fluency/model.subset.wordclasses.$MYLANG.h5" ]; then
		wget http://abumatran.eu/lms-eacl-2017/model.subset.wordclasses.$MYLANG.h5 -O "./fluency/model.subset.wordclasses.$MYLANG.h5"
	fi

	for FILE in systems/??$MYLANG-?mt1.tok.true ; do
					echo "$FILE" >> fluency/results
					THEANO_FLAGS=device=cpu,floatX=float32,on_unused_input=ignore $THEANOLM score "./fluency/model.subset.wordclasses.$MYLANG.h5" $FILE --output perplexity >> fluency/results
	done



done

}


#Reordering (Section 5)
function sort_alignments {
python -c '
import sys
for line in sys.stdin:
        line=line.rstrip("\n")
        parts=line.split(" ")
        als=[]
        for part in parts:
                st=part.split(":")
                als.append( (int(st[0])-1, int(st[1])-1 )  )

        print " ".join( str(a[0])+"-"+str(a[1]) for a in  sorted(als,key= lambda a: a[0]))
'
}

function count_words_per_line {
        paste $1 $2 | python -c '
import sys
for line in sys.stdin:
        line=line.rstrip("\n")
        partstab=line.split("\t")
        print str(len(partstab[0].strip().split(" ")))+"\t"+str(len(partstab[1].strip().split(" ")))
'
}

function compute_reordering {
	local SL=$1
	local TL=$2

  REFSPREFIX=`readlink -f "./references/newstest2016"`
	MTOUTSDIR=`readlink -f "./systems"`
	REPO=`readlink -f ./code`
  SIZE="big"


	INVPAIR="$TL-$SL"

	SLTEST=$REFSPREFIX-$SL$TL-src.$SL.tok.true
  TLSMT=$MTOUTSDIR/$SL$TL-smt1.tok.true
  TLNMT=$MTOUTSDIR/$SL$TL-nmt1.tok.true
  TLTEST=$REFSPREFIX-$SL$TL-ref.$TL.tok.true

  SIZETEST=`cat $SLTEST | wc -l`
  SIZE2=`expr $SIZETEST '*' 2`
  SIZE3=`expr $SIZETEST '*' 3`

  pushd reordering  > /dev/null

  #permutations and kendall's tau scores
  count_words_per_line $SLTEST $TLTEST > alignment-$SIZE-$PAIR/numwords-ref
  count_words_per_line $SLTEST $TLSMT > alignment-$SIZE-$PAIR/numwords-smt
  count_words_per_line $SLTEST $TLNMT > alignment-$SIZE-$PAIR/numwords-nmt

  cat alignment-$SIZE-$PAIR/alignments-ref | sort_alignments >  alignment-$SIZE-$PAIR/sortedals-ref
  cat alignment-$SIZE-$PAIR/alignments-smt | sort_alignments >  alignment-$SIZE-$PAIR/sortedals-smt
  cat alignment-$SIZE-$PAIR/alignments-nmt  |  sort_alignments >  alignment-$SIZE-$PAIR/sortedals-nmt

	paste alignment-$SIZE-$PAIR/sortedals-ref alignment-$SIZE-$PAIR/numwords-ref | $REPO/permutations/kendall-mono > alignment-$SIZE-$PAIR/kendallmono-ref 2> alignment-$SIZE-$PAIR/kendallmono-ref.err
  paste alignment-$SIZE-$PAIR/sortedals-smt alignment-$SIZE-$PAIR/numwords-smt | $REPO/permutations/kendall-mono > alignment-$SIZE-$PAIR/kendallmono-smt 2> alignment-$SIZE-$PAIR/kendallmono-smt.err
  paste alignment-$SIZE-$PAIR/sortedals-nmt alignment-$SIZE-$PAIR/numwords-nmt | $REPO/permutations/kendall-mono > alignment-$SIZE-$PAIR/kendallmono-nmt 2> alignment-$SIZE-$PAIR/kendallmono-nmt.err

	paste alignment-$SIZE-$PAIR/sortedals-smt alignment-$SIZE-$PAIR/numwords-smt  alignment-$SIZE-$PAIR/sortedals-ref alignment-$SIZE-$PAIR/numwords-ref |  $REPO/permutations/kendall > alignment-$SIZE-$PAIR/kendall-smt-vs-ref 2> alignment-$SIZE-$PAIR/kendall-smt-vs-ref.err
  paste alignment-$SIZE-$PAIR/sortedals-nmt alignment-$SIZE-$PAIR/numwords-nmt  alignment-$SIZE-$PAIR/sortedals-ref alignment-$SIZE-$PAIR/numwords-ref |  $REPO/permutations/kendall > alignment-$SIZE-$PAIR/kendall-nmt-vs-ref 2> alignment-$SIZE-$PAIR/kendall-nmt-vs-ref.err

	#avg distances for each sentence
  REORDSMT=`cat alignment-$SIZE-$PAIR/kendallmono-smt  | awk '{s+=$1; n++ }  END {print s/n}'`
  REORDNMT=`cat alignment-$SIZE-$PAIR/kendallmono-nmt | awk '{s+=$1; n++ } END {print s/n}'`
  REORDREF=`cat alignment-$SIZE-$PAIR/kendallmono-ref | awk '{s+=$1; n++} END {print s/n}'`

  PSMTREF=`cat alignment-$SIZE-$PAIR/kendall-smt-vs-ref | awk '{s+=$1; n++} END {print s/n}'`
  PNMTREF=`cat alignment-$SIZE-$PAIR/kendall-nmt-vs-ref | awk '{s+=$1; n++} END {print s/n}'`

  echo "$PAIR       $REORDSMT       $REORDNMT       $REORDREF       $PSMTREF        $PNMTREF" >> results
  python $REPO/paired-boostrap-sentence-level.py  alignment-$SIZE-$PAIR/kendall-smt-vs-ref alignment-$SIZE-$PAIR/kendall-nmt-vs-ref > alignment-$SIZE-$PAIR/paired-bootstrap

  popd > /dev/null

}


# Scores by sentence length (Section 6)
function scores_by_length {
	echo "----- scores_by_length -----"
	SL=en
	for TL in cs de fi ro ru; do
		LP=$SL$TL
		echo "$LP"
		mkdir -p scores_by_length/$LP
		python code/scores_by_length.py \
			$LP \
			references/newstest2016-$LP-src.$SL references/newstest2016-$LP-ref.$TL \
			systems/$LP-smt1 systems/$LP-nmt1
	done

	TL=en
	for SL in cs de ro ru; do
		LP=$SL$TL
		echo "$LP"
		mkdir -p scores_by_length/$LP
		python code/scores_by_length.py \
			$LP \
			references/newstest2016-$LP-src.$SL references/newstest2016-$LP-ref.$TL \
			systems/$LP-smt1 systems/$LP-nmt1
	done
}


# Error categories (Section 7)
function hjerson {
	echo "----- hjerson -----"
	SL=en

	for TL in ru de fi ro ru; do
		for S in nmt1 smt1; do
			echo "  systems/$SL$TL-$S"
			$HJERSON \
				-R references/newstest2016-$SL$TL-ref.$TL.tok.true \
				-B references/newstest2016-$SL$TL-ref.$TL.tok.true.base \
				-H systems/$SL$TL-$S.tok.true \
				-b systems/$SL$TL-$S.tok.true.base \
				-s hjerson/$SL$TL-$S.sents \
				-c hjerson/$SL$TL-$S.cats \
				-m hjerson/$SL$TL-$S.html \
				> hjerson/$SL$TL-$S.out

			# formatting, for results table
			cat hjerson/$SL$TL-$S.out | tr -s ' ' | cut -f3 > hjerson/$SL$TL-$S.errs
		done
	done

	TL=cs
	for STEM_MODE in light aggressive; do
		for S in nmt1 smt1; do
			echo "  systems/$SL$TL-$S $STEM_MODE"
			$HJERSON \
				-R references/newstest2016-$SL$TL-ref.$TL.tok.true \
				-B references/newstest2016-$SL$TL-ref.$TL.tok.true.base-$STEM_MODE \
				-H systems/$SL$TL-$S.tok.true \
				-b systems/$SL$TL-$S.tok.true.base-$STEM_MODE \
				-s hjerson/$SL$TL-$S-$STEM_MODE.sents \
				-c hjerson/$SL$TL-$S-$STEM_MODE.cats \
				-m hjerson/$SL$TL-$S-$STEM_MODE.html \
				> hjerson/$SL$TL-$S-$STEM_MODE.out

			# formatting, for results table
			cat hjerson/$SL$TL-$S-$STEM_MODE.out | tr -s ' ' | cut -f3 > hjerson/$SL$TL-$S-$STEM_MODE.errs
		done
	done

	TL=en
	for SL in cs de ro ru; do
		for S in nmt1 smt1; do
			echo "  systems/$SL$TL-$S"
			$HJERSON \
				-R references/newstest2016-$SL$TL-ref.$TL.tok.true \
				-B references/newstest2016-$SL$TL-ref.$TL.tok.true.base \
				-H systems/$SL$TL-$S.tok.true \
				-b systems/$SL$TL-$S.tok.true.base \
				-s hjerson/$SL$TL-$S.sents \
				-c hjerson/$SL$TL-$S.cats \
				-m hjerson/$SL$TL-$S.html \
				> hjerson/$SL$TL-$S.out

			# formatting, for results table
			cat hjerson/$SL$TL-$S.out | tr -s ' ' | cut -f3 > hjerson/$SL$TL-$S.errs
		done
	done

}


# ----------- overlaps (Section 3) (Results based on CHRF are shown in the paper)
mkdir -p overlaps/
rm -f overlaps/overlaps.out

SL=en
for TL in "cs" "de" "fi" "ro" "ru"; do
	overlap_metric $SL$TL BLEU >> overlaps/overlaps.out
	overlap_metric $SL$TL CHRF >> overlaps/overlaps.out
done

SL=en
for TL in "cs" "de" "fi" "ro" "ru"; do
	overlap_metric $SL$TL BLEU >> overlaps/overlaps.out
	overlap_metric $SL$TL CHRF >> overlaps/overlaps.out
done

#---------- fluency (Section 4)
rm -f fluency/results
echo "Computing fluency information ..."
#install theanoLM
pip3 install --user TheanoLM==0.9.5
mkdir -p fluency
fluency
echo "... result is available at fluency/results"


#--------- reordering (Section 5)
echo "Computing reordering information ..."
pushd code/permutations
bash compile.sh
popd
rm -f reordering/results
for PAIR in "cs-en" "de-en" "en-cs" "en-de" "en-fi" "en-ro" "en-ru" "ro-en" "ru-en" ; do
        SL=`echo "$PAIR" | cut -f 1 -d '-'`
        TL=`echo "$PAIR" | cut -f 2 -d '-'`

	compute_reordering "$SL" "$TL"
echo "... result is available at reordering/results"

done


# ----------- scores by sentence length (Section 6)
mkdir -p scores_by_length/
scores_by_length > scores_by_length/scores_by_length.out


# ----------- hjerson (Section 7)
mkdir -p hjerson
hjerson
