#!/bin/bash

# downloads the parallel training data
function get_data_train_parallel {
	wget http://data.statmt.org/wmt16/translation-task/training-parallel-nc-v11.tgz
	wget http://data.statmt.org/wmt16/translation-task/training-parallel-ep-v8.tgz
}

get_data_train_parallel
