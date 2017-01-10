#!/bin/bash

MBLEU="perl third/moses/generic/scripts/generic/multi-bleu.perl"
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
rm overlaps/overlaps.out

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



# ----------- scores by sentence length (Section 6)
mkdir -p scores_by_length/
scores_by_length > scores_by_length/scores_by_length.out



# ----------- hjerson (Section 7)
mkdir -p hjerson
hjerson







