import os
import re
import logging
from slack_bolt import App
from slack_bolt.adapter.flask import SlackRequestHandler
from flask import Flask, request
from dotenv import load_dotenv
from app.bot import handle_message

load_dotenv()

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

slack_app = App(
    token=os.environ["SLACK_BOT_TOKEN"],
    signing_secret=os.environ["SLACK_SIGNING_SECRET"]
)

flask_app = Flask(__name__)
handler = SlackRequestHandler(slack_app)


@slack_app.event("app_mention")
def handle_mention(body, say):
    text = re.sub(r"<@\w+>", "", body["event"].get("text", "")).strip()
    user = body["event"].get("user", "there")
    logger.info(f"Received mention from user {user}: {text}")
    response = handle_message(text)
    logger.info(f"Responding with: {response}")
    say(f"<@{user}> {response}")


@slack_app.event("message")
def handle_direct_message(body, say):
    text = body["event"].get("text", "")
    user = body["event"].get("user", "there")
    channel_type = body["event"].get("channel_type", "")

    if channel_type == "im":
        logger.info(f"Received DM from user {user}: {text}")
        response = handle_message(text)
        logger.info(f"Responding with: {response}")
        say(response)


@flask_app.route("/slack/events", methods=["POST"])
def slack_events():
    return handler.handle(request)


@flask_app.route("/health", methods=["GET"])
def health():
    return {"status": "ok"}, 200


if __name__ == "__main__":
    port = int(os.environ.get("PORT", 3000))
    logger.info(f"Starting server on port {port}")
    flask_app.run(host="0.0.0.0", port=port)