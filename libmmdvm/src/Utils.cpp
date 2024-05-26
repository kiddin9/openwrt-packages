#include <string>

using namespace std;

namespace utils {

string ltrim(const string& str) {
    return str.substr(str.find_first_not_of(" \n\r\t")); 
}

string rtrim(const string& str) { 
    return str.substr(0, str.find_last_not_of(" \n\r\t") + 1); 
} 

string trim(const string& str){ 
    return ltrim(rtrim(str)); 
}

}