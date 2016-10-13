# slacklogging

A set of tools shamelessly pilfered from others and tied together to perform backups of public Slack channel logs in the form of static HTML pages.

# Dependencies

* nodejs (tested with versions 4.6 through latest. Probably works on versions >4.x)

```
$ cd some/local/directory
$ wget https://nodejs.org/download/release/latest/node-v6.8.0.tar.gz
$ cd node-v6.8.0
$ sudo ./configure
$ sudo make install -j10
```

* Python packages click, flask, markdown2, and emoji

```
$ pip install click flask markdown2 emoji
```

You will also need a slack authentication `token`, which may be generated here: https://api.slack.com/web

slack-history-export
--------------------

This module performs API calls to assemble JSON history files for public channels.

(https://www.npmjs.com/package/slack-history-export)

We have a modified captive version of this module which is installed locally within the slacklogging folder.
I've edited it to do some light preprocessing to make rendering the HTML easier.

This is a node module, so needs to be installed into/with nodejs. `slacklogger.sh --setup` takes care of this and must be run once.


slack-export-viewer
--------------------

This module takes "official" Slack archive tarballs and renders them as a flask webserver.
(https://github.com/hfaran/slack-export-viewer)

We again have a captive version of this package. I've modified it to play nicely with the
less-than-official JSON formats produced above and fixed a few bugs.


# Setup

After cloning this repo you make sure `slacklogger.sh` file is executible. If not:

```
$ cd slacklogging
$ chmod 777 slacklogger.sh
```

Next run `slacklogger.sh` with the setup flag:

```
$ ./slacklogging.sh --setup
```

# Usage

```
$ ./slacklogger.sh --help
```

Required arguments are a slack API token and output directory:

```
$ ./slacklogger.sh -t token -o ~/Desktop/slacklogger_test_dir
```

Where `token` is a file containing the Slack API token string.
This can be generated here: https://api.slack.com/web

Debugging
---------

`npm ERR! Error: failed to fetch from registry:`

This usually means your linux distribution is very old and therefore your version of nodejs is <4.x (with npm version <1.x).

You should install a more recent version of nodejs from source as written above in the dependencies section.



