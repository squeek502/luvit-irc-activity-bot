return {
  name = "squeek502/irc-activity-bot",
  version = "0.1.0",
  description = "irc bot that announces github activity",
  keywords = {"irc", "bot", "github"},
  homepage = "https://github.com/squeek502/luvit-irc-activity-bot",
  author = {
    name = "Ryan Liptak",
    url = "http://www.ryanliptak.com"
  },
  dependencies = {
    "luvit/luvit@2.1.1",
    "squeek502/irc@0.3.1",
    "squeek502/poller@0.2.1"
  },
  files = {
    "!tests",
    "**.lua"
  }
}
