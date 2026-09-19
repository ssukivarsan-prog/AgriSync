import os, dotenv
from twilio.rest import Client

dotenv.load_dotenv(".env")
client = Client(os.getenv("TWILIO_ACCOUNT_SID"), os.getenv("TWILIO_AUTH_TOKEN"))

calls = client.calls.list(limit=5)
print(f"Found {len(calls)} recent calls:")
for c in calls:
    print(f"SID: {c.sid}, Status: {c.status}, Duration: {c.duration}, To: {c.to}, From: {c.from_formatted}")
    print(f"  URI: {c.uri}")
    print(f"  Direction: {c.direction}")
    print(f"  Subresource URIs: {c.subresource_uris}")
