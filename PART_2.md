# Part 2: The Front-End with Ember and the Ember CLI

*Last updated: November 28th, 2014*

*Looking for [Part 1?](PART_1.md)*

So, you've got the API and a sleek new CMS to manage your data layer. Now what?

Celebrate.

Repeat the celebration as much as you see fit and then come back here because we are going to get our hands dirty and build a front-end with Ember.js.

## It's Always Sunny in Ember.js

Ember.js has a gang now. It's got a lot of characters and it could be quite daunting for someone without any knowledge of how the different pieces fit and play along. Some call this Ember's "learning cliff". Ember's "learning cliff" is tough, but it instills a bit of what makes server-side frameworks like Rails so nice...

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

## Ember Data

To get Ember Data to communicate with our [Rails API from Part 1](PART_1.md) we need to set up a few things. Use the CLI to generate an adapter...

    ember generate adapter application

Now open and edit `app/adapters/application.js`...

```javascript
import DS from 'ember-data';

export default DS.ActiveModelAdapter.extend({
  namespace: 'api/v1',
  host: 'http://localhost:3000'
});
```

What we've done here is told Ember Data how to connect to the correct API host. It also namespaces each call to fetch records with our API's prefix. Since we are using the `active_model_serializers` gem on our Rails API, we can serialize/deserialize the JSON correctly by utilizing the `DS.ActiveModelAdapter`.

## The Router

We need a way to direct our users to our contacts page to show them a list of contacts and then click into them and get the contact's details.

Edit `app/router.js`...

```javascript
import Ember from 'ember';
import config from './config/environment';

var Router = Ember.Router.extend({
  location: config.locationType
});

Router.map(function() {
  this.resource('contacts', function() {
    this.resource('contact', { path: '/:contact_id' });
  });
});

export default Router;
```

## Templates

Our routes are set up so now we can add some links to get users to them. Edit the `app/templates/application.hbs` template...

```handlebars
<h2>Biznz</h2>

<ul>
  <li>{{link-to 'Home' 'index'}}</li>
  <li>{{link-to 'Contacts' 'contacts'}}</li>
</ul>

<hr>

{{outlet}}
```

Okay, so that's our basic frame. Very business-like.

## Models

Generate a model to start pulling in that API data and encapsulating it as an Ember object...

    ember generate model contact

Let's set up the attributes of the contact model. Edit `app/models/contact.js`...

```javascript
import DS from 'ember-data';

export default DS.Model.extend({
  firstName: DS.attr('string'),
  lastName: DS.attr('string'),
  email: DS.attr('string'),
  title: DS.attr('string'),
  createdAt: DS.attr('date'),
  updatedAt: DS.attr('date')
});
```

## Routes

We now need a route for our contacts...

    ember generate route contacts/index

Edit `app/routes/contacts/index.js`...

```javascript
import Ember from 'ember';

export default Ember.Route.extend({
  model: function() {
    return this.store.find('contact');
  }
});
```

## Tied Together

With this new route, we can edit its template that the Ember CLI generated for us. Edit `app/templates/contacts/index.hbs`...

```handlebars
<ul>
  {{#each}}
    <li>
      {{#link-to 'contact' this}}
        {{lastName}},
        {{firstName}}
      {{/link-to}}
    </li>
  {{else}}
    <li>No contacts found.</li>
  {{/each}}
</ul>
```

Great. Now, we've got some contacts showing up. But, we probably want to have a route for a detail page of each contact. We used the `link-to` Handlebars helper and passed it the route and a context. Let's create that `contact` route...

    ember generate route contact

Edit `app/routes/contact.js`...

```javascript
import Ember from 'ember';

export default Ember.Route.extend({
  model: function(params) {
    return this.store.find('contact', params.contact_id);
  }
});
```

This will use the params from the URL to reach into Ember Data's `store` and return the contact we want. Let's work on displaying some detail information. A template for the detail information was generated with our route. Edit `app/templates/contact.hbs`...

```handlebars
<h1>{{firstName}} {{lastName}}</h1>

<dl>
  <dt>Email</dt>
  <dd>{{email}}</dd>

  <dt>Title</dt>
  <dd>{{title}}</dd>
</dl>

<p>
  Updated at: {{updatedAt}}
  <br>
  Created at: {{createdAt}}
</p>
```

This is awesome. We built an application! Pop the champ'. But, wow, that date in the detail page for a contact looks like straight nerd garbage. Let's fix that.

## In The Moment(.js)

Ember Data is grabbing the date information from our JSON API responses and is spilling out the dates like this right now...

`Thu Jul 03 2014 10:59:55 GMT-0500 (CDT)`

Gross.

We can do better, people.

Let's add in [Moment.js](http://momentjs.com) and format those dates up.

First, add Moment.js with Bower...

    bower install moment --save

Now, we can import it to our Ember CLI application. Edit `Brocfile.js`...

```javascript
/* global require, module */

var EmberApp = require('ember-cli/lib/broccoli/ember-app');

var app = new EmberApp();

// Use `app.import` to add additional libraries to the generated
// output files.
//
// If you need to use different assets in different
// environments, specify an object as the first parameter. That
// object's keys should be the environment name and the values
// should be the asset to use in that environment.
//
// If the library that you are including contains AMD or ES6
// modules that you would like to import into your application
// please specify an object with the list of modules as keys
// along with the exports of each module as its value.

app.import('bower_components/moment/moment.js');

module.exports = app.toTree();
```

Generate our very first helper...

    ember generate helper formatted-date

And edit `app/helpers/formatted-date.js`...

```javascript
/* global moment:true */

import Ember from 'ember';

export default Ember.Handlebars.makeBoundHelper(function(date, format) {
  return moment(date).format(format);
});
```

Notice how we had to tell JSHint to shut up. It's because Moment.js has a global it doesn't know about. You could choose to add that to your `.jshintrc` file in the `"predef"` section.

Put that helper to work on our contact detail template. Edit `app/templates/contact.hbs`...

```handlebars
<h1>{{firstName}} {{lastName}}</h1>

<dl>
  <dt>Email</dt>
  <dd>{{email}}</dd>

  <dt>Title</dt>
  <dd>{{title}}</dd>
</dl>

<p>
  Updated at: {{formatted-date updatedAt 'MMMM Do, YYYY [at] h:mm a'}}
  <br>
  Created at: {{formatted-date createdAt 'MMMM Do, YYYY [at] h:mm a'}}
</p>
```

This outputs the dates nicely as...

`July 3rd, 2014 at 10:59 am`

Looks good to me.

## More Coming Soon...

I plan on making more parts and showing more of the Ember CLI and how to leverage some of the cool things that are happening with Ember CLI Add-Ons. Check back for more updates.
