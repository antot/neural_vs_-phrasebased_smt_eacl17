#!/usr/bin/python

import codecs
import sys
import nltk.data


language = sys.argv[1]

UTF8Reader = codecs.getreader('utf8')
sys.stdin = UTF8Reader(sys.stdin)
for _ in sys.stdin:
	sent_tokenised = ""
	text8=_.strip()
	for word in nltk.tokenize.word_tokenize(text8, language):
		sent_tokenised += word + " "

	print sent_tokenised.encode('utf8').rstrip()
