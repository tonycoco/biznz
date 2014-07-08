# Part 2: The Front-End

So, you've got the API and a sleek new CMS to manage your data layer. Now what?

Celebrate.

Repeat the celebration as much as you see fit and then come back here because we are going to get our hands dirty and build a front-end with Ember.js.

## It's Always Sunny in Ember.js

Ember.js has a gang now. It's got a lot of characters and it could be quite daunting for someone without any knowledge of how the different pieces fit and play along. Some call this Ember's "learning cliff". Ember's learning cliff is tough, but it instills a bit of what makes server-side frameworks like Rails so nice...

Conventions.

Here are the basics about a standard Ember.js stack:

1. Node.js and NPM handle the dependencies.
2. Ember.js is a client-side JavaScript framework.
3. Ember Data is a data persistence library for Ember.js.
4. Ember CLI is an Ember application command line utility.

You're going to need to know a bit about each part. Not just that, but also a bit on how Ember.js itself is structured. Here are some relevant links...

* [Ember.js Guides](http://emberjs.com/guides)
* [Ember CLI Documentation](http://iamstef.net/ember-cli)
* ["Ember Data: A Comprehensive Tutorial for the ember-data Library" by Pooyan Khosravy](http://www.toptal.com/emberjs/a-thorough-guide-to-ember-data)

## Ember CLI

We are going to use the Ember CLI to generate some files for us and give us a sane upgrade path. Fire away and install the binaries we are going to use...

    npm install -g bower
    npm install -g ember-cli

Once that is all finished downloading and installing we can get to work.

### Starting A New Application

Let's create a new Ember application with the CLI. I'm so [excited](https://www.youtube.com/watch?v=b95oyhSd5ls)...

    ember new front-end
    cd front-end

Bakawh! Ember. Looking like Rails? Yep. That's the point. The Ember.js team is striving to make this framework simple to get up and running with scissors (also known as: JavaScript).

Check to make sure everything is working...

    ember server

Wait for it... Next, point your browser at `http://localhost:4200` and see the "Welcome to Ember.js" heading on your screen.

See it? Good. Let's move on.

### Need Help?

The Ember CLI has a bunch of great tasks it can help out with. Check them out...

    ember --help
    ember generate --help

### Add-Ons and Ember Data

We need to add in Ember Data. The Ember CLI makes this easy with add-ons (Read: ["Introducing Ember CLI Addons" by Robert Jackson](http://reefpoints.dockyard.com/2014/06/24/introducing_ember_cli_addons.html)). Install the Ember Data add-on...

    npm install --save-dev ember-cli-ember-data

Now, go ahead and reboot that `ember server`. Kill the process with `CTRL+C`. Again...

    ember server    

To get Ember Data to communicate with our [Rails API from Part 1](PART_1.md) we need to set up a few things. Open and edit ``...