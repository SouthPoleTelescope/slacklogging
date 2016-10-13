# slacklogging

A set of tools shamelessly pilfered from others and tied together to perform backups of public Slack channel logs in the form of static HTML pages.

# Dependencies

This *should* be relatively self-contained.
It uses modified versions of two different packages:

slack-history-export
--------------------

This module performs API calls to assemble JSON history files for public channels.

(https://www.npmjs.com/package/slack-history-export)

We have a modified captive version of this module which is installed locally within the slacklogging folder.
I've edited it to do some light preprocessing to make the rendering of the HTML easier.

`slacklogger` takes care of the installation and setup.


slack-export-viewer
--------------------

This module takes "official" Slack archive tarballs and renders them as a flask webserver.
(https://github.com/hfaran/slack-export-viewer)

We again have a captive version of this package. I've modified it to play nicely with the
less-than-official JSON formats produced above.

It does have its own dependencies, which are not installed by `slacklogger.sh` and you may have to install them:

* click
* flask
* markdown2
* emoji

# Setup

After cloning this repo you must first edit the `slacklogger.sh` file to be executible:

```
$ cd slacklogging
$ chmod 777 slacklogger.sh
```

Next run `slacklogger.sh` with the setup flag:

```
$ ./slacklogging.sh --setup
```

All messages related to this process can be found in the `slacklogging/setup.log` file.


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


