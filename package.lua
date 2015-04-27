return {
  name = "squeek502/irc-activity-bot",
  version = "0.1.0",
  description = "irc bot that announces github activity",
  author = {
    name="squeek"
  },
  dependencies = {
    "luvit/luvit@2.1.0",
    "squeek502/irc@0.3.1",
    "squeek502/poller@0.2.0"
  },
  files = {
    "!tests",
    "**.lua"
  }
}
