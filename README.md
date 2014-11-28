# Rails + Ember.js (with the Ember CLI): Redux

*Last updated: November 28th, 2014*

I'm a big fan of stealing.

No, not the kind that can land you behind bars, but the good kind. The open-sourced kind. More like... borrowing.

We often find ourselves building the same patterns and bricks of code. That's not really going to benefit anyone in the long run. Finding the right libraries and frameworks to lift the heavy and tedious boilerplate work can make your life easier.

This is why Ruby on Rails became a household name. Gone were the days of figuring out how to route a request to some code, open a connection and query the database for a record, create an object from that record, set up a MVC structure and so much more. Rails took care of that for you. It had and continues to have strong conventions and opinions. Frameworks, like Rails and Ember.js, make the "unimportant" design decisions in your application so you can try to focus on the important ones (Read: ["The Framework isn't for You" by Joe Hirn](http://www.devmynd.com/blog/2014-5-the-framework-isn-t-for-you)). So, why do we keep building the same building blocks over and over?

I have no idea.

I'm going to be honest here, I'd much rather tape together a bunch of open-source projects. These projects, for the most part, were built and are being built to solve problems that someone else already strangled to death for us.

The benefit of leveraging the community at large is easy to articulate. It is not just *your solution*. It's, for the most part, *the solution*. Most popular gems, Rails conventions, Ember.js conventions have been built for the "90% of the time" solution to the problem. Plus, they are often tried and tested against multiple environments. Bugs have already been squashed. Refactors have been made.

## Overview

In this series of blog posts I'd like to try to build a simple API and front-end application stack. (Note: I'm going to overuse the word "leverage" a ton. Just deal with it.) I'll try to leverage as many open-sourced libraries and frameworks to make our API and front-end application stacks simple and easy to follow.

Dependenices...

- PostgreSQL
- Ruby 2.1.5
- Node.js and NPM

Here's what we will be using...

- [Rails](http://rubyonrails.org)
  - [ActiveAdmin](http://activeadmin.info/)
  - [Grape API](https://github.com/intridea/grape)
    - [Swagger Documentation](http://swagger.wordnik.com) with [grape-swagger](https://github.com/tim-vandecasteele/grape-swagger)
  - [ActiveModelSerializers](https://github.com/rails-api/active_model_serializers)
- [Ember.js](http://emberjs.com)
  - [Ember CLI](https://github.com/stefanpenner/ember-cli)
  - ActiveModelSerializer Adapters

## The Tutorial

First, get PostgreSQL up and running. Done? Okay, now you're ready to rock.

Create a folder to put both our Rails API application and our Ember.js front-end application in...

    mkdir biznz
    cd biznz

Since this application is going to be so Web 2.0, I left out a bunch of letters for us. Yes, this will be a simple business application tutorial... boo. I'll do my best to make follow-up posts making this example a bit more involved.

## The Saga

There are 2 parts available so far...

- [Part 1: The API and CMS](PART_1.md)
- [Part 2: The Front-End](PART_2.md)
