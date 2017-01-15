#include "Permutation.h"
#include <iostream>
#include <boost/algorithm/string.hpp>

int main() {
	for (std::string line; std::getline(std::cin, line);) {
 	std::vector<std::string> strs;
	boost::split(strs, line, boost::is_any_of("\t"));	
        
	MosesTuning::Permutation p1(strs[0],atoi(strs[1].c_str()),atoi(strs[2].c_str()));
	MosesTuning::Permutation p2(strs[3],atoi(strs[4].c_str()),atoi(strs[5].c_str()));

	std::cout <<  p1.distance(p2,MosesTuning::KENDALL_DISTANCE)  << std::endl;
    }
}
