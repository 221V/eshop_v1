Erlang shop prototype v1
===========================

simple shop (without user registration) with telegram bot order-message into channel/groupchat

-------------
Prerequisites
-------------
* erlang (v 20 or higher)
* postgresql (v 9.5 or higher)
* pgbouncer (optional - change port to postgresql)
* nginx (optional - change websocket_port to default)
* letsencrypt certbot or acme.sh (optional)
* make
* inotify-tools (Linux, for filesystem watching)

Includes
---
* n2o ( github.com/synrc/n2o )
* nitro ( github.com/synrc/nitro )
* mad ( github.com/synrc/mad )
* otp.mk ( github.com/synrc/otp.mk )
* erlydtl ( github.com/evanmiller/erlydtl )
* epgsql ( github.com/epgsql/epgsql )
* vanilla.js ( vanilla-js.com )

Run
---
On Linux

1 -- create telegram bot, get bot token
2 -- install nginx, erlang, postgresql, other
3 -- put this code, edit settings in sys.config and run

    $ ./mad deps compile plan repl
    $ CTRL + C
    $ make start
    $ make attach
    $ CTRL + D


Thanks
---
* thank you, n2o developers ( github.com/synrc/n2o )
* thank you, erlang developers ( erlang.org, erlang-solutions.com )
* thank you, postgresql developers ( postgresql.org )
* thank you, nginx developers ( nginx.org )
* thank you, letsencrypt developers ( letsencrypt.org )
* thank you, telegram developers ( telegram.org )
* and more other people, including debian, ubuntu & lxde developers etc
Thank You, You make me happy :)


