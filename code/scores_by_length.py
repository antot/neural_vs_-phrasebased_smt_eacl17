#!/usr/bin/python

import sys
#import os
import subprocess

lp = sys.argv[1]
f_src = sys.argv[2]
f_ref = sys.argv[3]
f_sys1 = sys.argv[4]
f_sys2 = sys.argv[5]

with open(f_src) as f:
    src = f.readlines()
with open(f_ref) as f:
    ref = f.readlines()
with open(f_sys1) as f:
    sys1 = f.readlines()
with open(f_sys2) as f:
    sys2 = f.readlines()

if len(ref) != len(sys1) or len(ref) != len(sys2):
	print "Number of sentences in reference and systems should be equal"
	sys.exit(1)


length_groups = [[1,5],[6,10],[11,15],[16,20],[21,25],[26,30],[30,35],[36,40],[41,45], [46,50],[51,10000]]

#print len(length_groups)
srcs_by_length = [[] for y in range(len(length_groups))]
refs_by_length = [[] for y in range(len(length_groups))] 
sys1s_by_length = [[] for y in range(len(length_groups))] 
sys2s_by_length = [[] for y in range(len(length_groups))]  

for i in range(len(src)):
	num_tokens = len(src[i].split())
	for j in range(len(length_groups)):
		if num_tokens >= length_groups[j][0] and num_tokens <= length_groups[j][1]:
			srcs_by_length[j].append(src[i])
			refs_by_length[j].append(ref[i])
			sys1s_by_length[j].append(sys1[i])
			sys2s_by_length[j].append(sys2[i])
			break

#	print num_tokens, src[i]
#	if i>5:
#		break

#print "--------"
bleus = "BLEU\n"
chrfs = "CHRF1\n"
bleus_chrfs = "BLEU CHRF1\n"
for i in range(len(srcs_by_length)):
#	print i, length_groups[i][0], length_groups[i][1], len(srcs_by_length[i])

	with open("scores_by_length/" + lp + "/srcs" + str(i), 'w') as f:
		for j in srcs_by_length[i]:
			f.write(j)
	with open("scores_by_length/" + lp + "/refs" + str(i), 'w') as f:
		for j in refs_by_length[i]:
			f.write(j)
	with open("scores_by_length/" + lp + "/sys1s" + str(i), 'w') as f:
		for j in sys1s_by_length[i]:
			f.write(j)
	with open("scores_by_length/" + lp + "/sys2s" + str(i), 'w') as f:
		for j in sys2s_by_length[i]:
			f.write(j)


	bleu_score1 = subprocess.check_output("code/multi-bleu.perl scores_by_length/" + lp + "/refs" + str(i) + " < scores_by_length/" + lp + "/sys1s" + str(i), shell=True)
	bleu_score2 = subprocess.check_output("code/multi-bleu.perl scores_by_length/" + lp + "/refs" + str(i) + " < scores_by_length/" + lp + "/sys2s" + str(i), shell=True)

	bleu_score1 = float(bleu_score1.split(",")[0].split()[2])
	bleu_score2 = float(bleu_score2.split(",")[0].split()[2])
	bleu_perc = (float(bleu_score2) - float(bleu_score1)) / float(bleu_score1)

	bleus += "%d-%d %f %f %f %d\n" % (length_groups[i][0], length_groups[i][1], bleu_score1, bleu_score2,  bleu_perc, len(srcs_by_length[i]))


	chrf_score1 = subprocess.check_output("python code/chrF_maja.py -R scores_by_length/" + lp + "/refs" + str(i) + " -H scores_by_length/" + lp + "/sys1s" + str(i), shell=True)
	chrf_score2 = subprocess.check_output("python code/chrF_maja.py -R scores_by_length/" + lp + "/refs" + str(i) + " -H scores_by_length/" + lp + "/sys2s" + str(i), shell=True)

	chrf_score1 = float(chrf_score1.split("\t")[1])
	chrf_score2 = float(chrf_score2.split("\t")[1])
	chrf_perc = (float(chrf_score2) - float(chrf_score1)) / float(chrf_score1)

	chrfs += "%d-%d %f %f %f %d\n" % (length_groups[i][0], length_groups[i][1], chrf_score1, chrf_score2, chrf_perc, len(srcs_by_length[i]))

	bleus_chrfs +="%d-%d %f %f %d\n" % (length_groups[i][0], length_groups[i][1], bleu_perc, chrf_perc, len(srcs_by_length[i]))



print bleus
print chrfs
print bleus_chrfs
