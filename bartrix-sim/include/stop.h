#include <iostream>

// Example Parser for stops.txt
struct Stop
{
    std::string id;
    std::string code;
    std::string name;
    std::string desc;
    double stop_lat;
    double stop_lon;
    std::string zone_id;
    std::string plc_url;
    std::string location_type;
    std::string parent_station;
    std::string platform_code;

    // Parse a Stop from a CSV line
    static Stop from_csv_line(const std::string &line);

    // stringify
    std::string to_string() const;
};

std::vector<Stop> parse_stops();
