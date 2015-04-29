Luvit IRC Activity Bot
======================
IRC bot that announces Github activity for user/organization

Usage
-----
1. Install [lit and luvit](https://luvit.io/)
2. Clone this repository
3. Run `lit install` in the directory of the checked out repository
4. Copy config.example.lua to config.lua and edit it
5. Run `luvit .` in the directory of the checked out repository (a different config filename can be specified by running `luvit . [config_name]`, e.g. `luvit . altconfig`)

Running The Tests
-----------------
With luvit: `luvit ./tests`

With lit/luvi: `luvi tests .`

To only run a specific test (e.g. 'test-message.lua'): `luvit ./tests message` or `luvi tests . -- message`
