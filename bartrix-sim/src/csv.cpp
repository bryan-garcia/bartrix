#include <string>
#include <vector>
#include <sstream>
#include "csv.h"

/**
 * Split a CSV line into tokens, handling quoted strings with commas.
 *
 * @param line The CSV line to split.
 * @return A vector of tokens as strings.
 */
std::vector<std::string> split_csv_line(const std::string &line)
{
    std::istringstream ss(line);
    std::string token;
    std::vector<std::string> tokens;

    // Have to parse a bit funny to handle quoted strings
    // and commas inside quotes
    while (std::getline(ss, token, ','))
    {
        tokens.push_back(token);
    }

    std::vector<std::string> result;
    std::string current_token;
    bool in_quotes = false;
    for (auto &token : tokens)
    {
        current_token += token;
        if (token.front() == '"' && token.back() == '"')
        {
            result.push_back(remove_quotes(current_token));
            current_token.clear();
        }
        else if (token.front() == '"')
        {
            in_quotes = true;
            current_token += ",";
        }
        else if (token.back() == '"')
        {
            in_quotes = false;
            result.push_back(remove_quotes(current_token));
            current_token.clear();
        }
        else if (in_quotes)
        {
            current_token += ",";
        }
        else
        {
            result.push_back(current_token);
            current_token.clear();
        }
    }

    return result;
}

/** Remove quotes from a string if it is quoted.
 * @param str The input string.
 * @return The unquoted string.
 */
std::string remove_quotes(const std::string &str)
{
    if (str.size() >= 2 && str.front() == '"' && str.back() == '"')
        return str.substr(1, str.size() - 2);
    return str;
}
