#!/bin/bash

# downloads the monolingual training data
function get_data_train_mono {
	wget http://data.statmt.org/wmt16/translation-task/news.2015.cs.shuffled.gz
	wget http://data.statmt.org/wmt16/translation-task/news.2015.de.shuffled.gz
	wget http://data.statmt.org/wmt16/translation-task/news.2015.en.shuffled.gz
	wget http://data.statmt.org/wmt16/translation-task/news.2015.fi.shuffled.gz
	wget http://data.statmt.org/wmt16/translation-task/news.2015.ro.shuffled.gz
	wget http://data.statmt.org/wmt16/translation-task/news.2015.ru.shuffled.gz
}

get_data_train_mono
