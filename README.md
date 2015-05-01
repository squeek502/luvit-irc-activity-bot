Luvit IRC Activity Bot [![Build Status](https://travis-ci.org/squeek502/luvit-irc-activity-bot.svg)](https://travis-ci.org/squeek502/luvit-irc-activity-bot)
======================
IRC bot that announces Github activity for repositories/users/organizations

##### Example output:

![squeek502 pushed 1 commit(s) to squeek502/lit@patch-2 [https://github.com/squeek502/lit/commits/patch-2]](http://www.ryanliptak.com/misc/luvit-irc-activity-bot-preview.png)

Usage
-----
1. Install [lit and luvit](https://luvit.io/)
2. Clone this repository
3. Run `lit install` in the directory of the checked out repository
4. Copy config.example.lua to config.lua and edit it
5. Run `luvit .` in the directory of the checked out repository (a different config filename can be specified by running `luvit . [config_name]`, e.g. `luvit . altconfig`)

Running on Heroku
-----------------
1. Clone this repository
2. Create a new Heroku app using the [Luvit buildpack](https://github.com/squeek502/heroku-buildpack-luvit)
3. Add a Procfile containing `worker: luvit .` (assuming your config file is named `config.lua`)
4. Commit and push to Heroku
5. Scale the Heroku app's worker dynos to 1

##### On a Unix command line:
```shell
git clone https://github.com/squeek502/luvit-irc-activity-bot.git
cd luvit-irc-activity-bot
heroku create --buildpack https://github.com/squeek502/heroku-buildpack-luvit.git
cp config.example.lua config.lua
vi config.lua
echo "worker: luvit ." > Procfile
git add -a
git commit -m "Heroku setup"
git push heroku master
heroku ps:scale worker=1
```

##### On a Windows command line:
```bat
git clone https://github.com/squeek502/luvit-irc-activity-bot.git
cd luvit-irc-activity-bot
heroku create --buildpack https://github.com/squeek502/heroku-buildpack-luvit.git
copy config.example.lua config.lua
notepad config.lua
echo worker: luvit . > Procfile
git add -a
git commit -m "Heroku setup"
git push heroku master
heroku ps:scale worker=1
```

Running The Tests
-----------------
With luvit: `luvit ./tests`

With lit/luvi: `luvi tests .`

To only run a specific test (e.g. 'test-message.lua'): `luvit ./tests message` or `luvi tests . -- message`
