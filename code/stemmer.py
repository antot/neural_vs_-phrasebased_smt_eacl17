#!/usr/bin/python

import codecs
import sys
from nltk.stem import SnowballStemmer

language = sys.argv[1]

#TODO if language supported
stemmer = SnowballStemmer(language) 


UTF8Reader = codecs.getreader('utf8')
sys.stdin = UTF8Reader(sys.stdin)
for _ in sys.stdin:
	sent_stemmed = ""
	text8=_.strip()

	#TODO if language supported
	for word in text8.split():
		sent_stemmed += stemmer.stem(word) + " "
		
	print sent_stemmed.encode('utf8').rstrip()
