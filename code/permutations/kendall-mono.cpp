#include "Permutation.h"
#include <iostream>
#include <sstream>
#include <boost/algorithm/string.hpp>

int main() {
	for (std::string line; std::getline(std::cin, line);) {
 	std::vector<std::string> strs;
	boost::split(strs, line, boost::is_any_of("\t"));	
        


	MosesTuning::Permutation p2(strs[0],atoi(strs[1].c_str()),atoi(strs[2].c_str()));
	std::stringstream p1als;
	for(int i=0 ; i < atoi(strs[1].c_str()); i++){
		if(i > 0)
			p1als << " ";
		p1als << i << "-" <<i;
	}
	MosesTuning::Permutation p1(p1als.str(),atoi(strs[1].c_str()),atoi(strs[1].c_str()));

	std::cout <<  p1.distance(p2,MosesTuning::KENDALL_DISTANCE)  << std::endl;
    }
}
