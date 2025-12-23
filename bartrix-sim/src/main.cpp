#include <iostream>
#include <sstream>
#include <string>
#include <vector>
#include <curl/curl.h>
#include "stop.h"
#include "gtfs-realtime.pb.h"

// Globals
const std::string GTFS_URL = "https://api.bart.gov/gtfsrt/tripupdate.aspx";

// Callback function to handle the data received by libcurl
size_t writeFunction(void *ptr, size_t size, size_t nmemb, std::string *data)
{
    // Append the received data to the string
    data->append((char *)ptr, size * nmemb);
    // Return the number of bytes successfully processed
    return size * nmemb;
}

int main()
{
    // Initialize the libcurl library globally
    curl_global_init(CURL_GLOBAL_DEFAULT);

    // Create a CURL handle
    CURL *curl = curl_easy_init();

    if (curl)
    {
        std::string response_data;

        // Set the URL for the CURL request
        curl_easy_setopt(curl, CURLOPT_URL, GTFS_URL.c_str());
        // Set the write function callback to handle the response data
        curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, writeFunction);
        // Set the data pointer to pass to the write function
        curl_easy_setopt(curl, CURLOPT_WRITEDATA, &response_data);

        // Perform the CURL request
        CURLcode res = curl_easy_perform(curl);
        if (res != CURLE_OK)
        {
            std::cerr << "CURL request failed: " << curl_easy_strerror(res) << std::endl;
        }
        else
        {
            // Parse the GTFS-Realtime data
            transit_realtime::FeedMessage feed;
            if (feed.ParseFromString(response_data))
            {
                std::cout << "Successfully parsed GTFS-Realtime data." << std::endl;
                // Process the feed data as needed
                // Print first entity
                if (feed.entity_size() > 0)
                {
                    const transit_realtime::FeedEntity &entity = feed.entity(0);
                    std::cout << "First entity ID: " << entity.id() << std::endl;
                    std::cout << entity.DebugString() << std::endl;
                }
            }
            else
            {
                std::cerr << "Failed to parse GTFS-Realtime data." << std::endl;
            }
        }

        // Clean up the CURL handle
        curl_easy_cleanup(curl);
    }
    else
    {
        std::cerr << "Failed to initialize CURL." << std::endl;
    }

    // Clean up libcurl globally
    curl_global_cleanup();

    return 0;
}
