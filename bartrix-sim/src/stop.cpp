#include <iostream>
#include "csv.h"
#include "stop.h"
#include "bart/assets/stops_txt.h"

/** Parse a Stop from a CSV line
 * @param line The CSV line representing a Stop.
 * @return A Stop object.
 */
Stop Stop::from_csv_line(const std::string &line)
{
    Stop stop;
    auto tokens = split_csv_line(line);

    stop.id = tokens[0];
    stop.code = tokens[1];
    stop.name = tokens[2];
    stop.desc = tokens[3];
    stop.stop_lat = std::stod(tokens[4]);
    stop.stop_lon = std::stod(tokens[5]);
    stop.zone_id = tokens[6];
    stop.plc_url = tokens[7];
    stop.location_type = tokens[8];
    stop.parent_station = tokens[9];
    stop.platform_code = tokens[10];

    return stop;
}

/** Convert a Stop to a string representation
 * @return A string representation of the Stop.
 */
std::string Stop::to_string() const
{
    std::ostringstream oss;
    oss << "Stop(ID: " << id
        << ", Code: " << code
        << ", Name: " << name
        << ", Desc: " << desc
        << ", Lat: " << stop_lat
        << ", Lon: " << stop_lon
        << ", Zone ID: " << zone_id
        << ", PLC URL: " << plc_url
        << ", Location Type: " << location_type
        << ", Parent Station: " << parent_station
        << ", Platform Code: " << platform_code
        << ")";
    return oss.str();
}

/** Parse stops from embedded asset
 *
 * Uses the stops.txt embedded asset to parse and return a vector of Stop objects.
 * @return A vector of Stop objects.
 */
std::vector<Stop> parse_stops()
{
    std::vector<Stop> stops;
    std::istringstream ss(bart::assets::stops_txt);
    std::string line;

    // Skip header line
    std::getline(ss, line);

    while (std::getline(ss, line))
    {
        auto stop = Stop::from_csv_line(line);
        stops.push_back(stop);
    }

    return stops;
}
