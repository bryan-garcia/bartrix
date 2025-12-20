from google.transit import gtfs_realtime_pb2
import requests

GTFS_URL = "http://api.bart.gov/gtfsrt/tripupdate.aspx"

def main():
    feed = gtfs_realtime_pb2.FeedMessage()
    response = requests.get(GTFS_URL)
    feed.ParseFromString(response.content)
    for ent in feed.entity:
        print(ent)


if __name__ == "__main__":
    main()
