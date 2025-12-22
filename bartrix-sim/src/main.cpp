#include <iostream>
#include <sstream>
#include <string>
#include <vector>
#include "stop.h"

int main()
{
    std::vector<Stop> stops = parse_stops();
    std::cout << "First Stop: " << stops[0].to_string() << std::endl;

    return 0;
}
