# Part 1: The API and CMS with Ruby on Rails

*Last updated: November 28th, 2014*

Get this party started. Let's build an API and CMS to expose our data layer to the world.

## I Love Typing Rails New

Install the latest Rails gem...

    gem install rails

My favorite thing in the world is to start something brand new without and garbage...

    rails new api -T -d postgresql
    cd api

Okay. Thanks, Rails. You just gave us ~70% of what we needed to start this sucker. The `-T` switch tells Rails we are not going to use `TestUnit` and the `-d postgresql` switch tells Rails that we want to use a PostgreSQL database.

## Gems

We need to add a bunch of gems now. Edit the `Gemfile` and add...

```ruby
gem "activeadmin", github: "gregbell/active_admin" # Until it's 1.0.0
gem "devise"

group :development do
  gem "better_errors"
  gem "meta_request"
  gem "quiet_assets"
end

group :development, :test do
  gem "capybara"
  gem "capybara-screenshot"
  gem "database_cleaner"
  gem "factory_girl_rails"
  gem "faker"
  gem "poltergeist"
  gem "pry-nav"
  gem "pry-rails"
  gem "pry-stack_explorer"
  gem "pry-theme"
  gem "rspec-rails"
  gem "rubocop"
  gem "shoulda-matchers"
  gem "spring-commands-rspec"
end
```

I won't go into any detail here, these are mostly to make your life as a developer easier. Feel free to look each of them up on [RubyGems.org](http://rubygems.org).

You can also comment out a few gems that we aren't going to need...

```ruby
# gem 'coffee-rails', '~> 4.0.0'
# gem 'turbolinks'
# gem 'jbuilder', '~> 2.0'
# gem 'sdoc', '~> 0.4.0',          group: :doc
```

And now, bundle it all up...

    bundle install

## Generators

Let's generate a few things for these gems too...

    bundle exec rails generate rspec:install
    bundle exec rails generate active_admin:install
    bundle exec spring binstub --all
    bundle exec rake db:create db:migrate

## Spec Runner

The newest versions of Rspec output all warnings. It's ridiculous. Let's remove that before we begin. In the `.rspec` file remove the line...

    --warnings

Let's try to run the specs...

    bundle exec rake

You should get some pending specs for the `AdminUser` model that ActiveAdmin generated for us. No worries. We love freebies.

## Serve It Up

Start your Rails server...

    bundle exec rails server

Now, open your web browser to `http://localhost:3000/admin`. You should get a log in screen. Good thing for us is that ActiveAdmin's generator also created a user for us to use...

Email: `admin@example.com`
Password: `password`

Yes, this is not the most secure thing to keep in your database, but it's great for quick examples like this. You should see an admin dashboard once you log in.

## Let's Make a Resource

We are going to generate a `Contact` model for us to administrate with ActiveAdmin...

    bundle exec rails generate model contact first_name:string last_name:string email:string title:string

And the ActiveAdmin DSL file...

    bundle exec rails generate active_admin:resource contact

But, we need to make sure the params are permitted. Edit `app/admin/contact.rb`...

```ruby
ActiveAdmin.register Contact do
  permit_params :id, :first_name, :last_name, :email, :title, :created_at, :updated_at
end
```

Now, migrate the database up...

    bundle exec rake db:migrate

Perf. Now, we've got a model and ActiveAdmin's users can edit them. Try it for yourself by going to `http://localhost:3000/admin/contacts`.

## Exposing an API

Eventually, our Ember.js application is going to use Ember-Data to grab records over the wire and create Ember Objects for our front-end application to use. We are going to expose an API layer from the Rails application using Grape's API gem. Let's add in a few useful gems to our `Gemfile`...

```ruby
gem "active_model_serializers"
gem "grape"
gem "grape-active_model_serializers"
gem "grape-swagger-rails"
gem "rack-cors", require: "rack/cors"
```

And...

    bundle install

CORS. F CORS. This part sucks, but we have to allow our API to easily connect to our Front-End application (Read: ["Understanding Cross-Origin Resource Sharing (CORS)" by Brian Rinaldi](http://www.adobe.com/devnet/html5/articles/understanding-cross-origin-resource-sharing-cors.html)). Edit `config/application.rb`...

```ruby
require File.expand_path("../boot", __FILE__)

require "rails/all"

Bundler.require(*Rails.groups)

module Api
  class Application < Rails::Application
    config.middleware.use Rack::Cors do
      allow do
        origins "*"
        resource "*", headers: :any, methods: [:get, :post, :put, :delete, :options]
      end
    end
  end
end
```

Now, let's generate the serializer that we can use with our `Contact` model using the [active_model_serializers](https://github.com/rails-api/active_model_serializers) gem...

    bundle exec rails generate serializer contact

This new serializer needs a few attributes exposed. Edit the `app/serializers/contact.rb` file...

```ruby
class ContactSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :email, :title, :created_at, :updated_at
end
```

Finally, we get to the creating the API endpoints that our Ember.js application will eventually grab data from. Add the following to `config/routes.rb` file...

```ruby
mount API::Base, at: "/"
mount GrapeSwaggerRails::Engine, at: "/documentation"
```

And, we need to create our `API::Base` class that we just *claimed* is there. Edit a file, `app/controllers/api/base.rb`...

```ruby
module API
  class Base < Grape::API
    mount API::V1::Base
  end
end
```

So, what we are doing here is pretty solid. We are creating a base class for our Rails application to mount to the `/` route. Then, we are mounting more Grape API parts in to that base class. We are going to follow the `/api/v1` route version prefixing. I know people have some extremely passionate opinions about that URL structure. For the example here, I'm going to pull a Montell Jordan and say, ["This Is How We Do It"](https://www.youtube.com/watch?v=0hiUuL5uTKc). Though, it's not Friday night... yet.

*Note: We piggyback on the `app/controllers` directory's autoloading from Rails, thus why our `api` directory is placed in there. You could very well just place these Grape API parts in `app/api` or something like that. You'll just have to add some things to let Rails know that you want those application folders to get autoloader correctly.*

Again, we mounted that base class with another class, a "v1" of our API. Great, let's create that file at `app/controllers/api/v1/base.rb`...

```ruby
require "grape-swagger"

module API
  module V1
    class Base < Grape::API
      mount API::V1::Contacts
      # mount API::V1::AnotherResource

      add_swagger_documentation(
        api_version: "v1",
        hide_documentation_path: true,
        mount_path: "/api/v1/swagger_doc",
        hide_format: true
      )
    end
  end
end
```

We can now start our `app/controllers/api/v1/contacts.rb` file...

```ruby
module API
  module V1
    class Contacts < Grape::API
      include API::V1::Defaults

      resource :contacts do
        desc "Return all contacts"
        get "", root: :contacts do
          Contact.all
        end

        desc "Return a contact"
        params do
          requires :id, type: String, desc: "ID of the contact"
        end
        get ":id", root: "contact" do
          Contact.where(id: permitted_params[:id]).first!
        end
      end
    end
  end
end
```

This will create two endpoints for our API. A basic `GET` for an index listing and a `GET` for a singular resource. This should look familiar to anyone that has used Rails' scaffolding.

If you've noticed that `API::V1::Defaults` mix-in, you're on top of your stuff. I found this pattern to be useful. Edit a file called `app/controllers/api/v1/defaults.rb`. Here's why it's so useful to us...

```ruby
module API
  module V1
    module Defaults
      extend ActiveSupport::Concern

      included do
        prefix "api"
        version "v1", using: :path
        default_format :json
        format :json
        formatter :json, Grape::Formatter::ActiveModelSerializers

        helpers do
          def permitted_params
            @permitted_params ||= declared(params, include_missing: false)
          end

          def logger
            Rails.logger
          end
        end

        rescue_from ActiveRecord::RecordNotFound do |e|
          error_response(message: e.message, status: 404)
        end

        rescue_from ActiveRecord::RecordInvalid do |e|
          error_response(message: e.message, status: 422)
        end
      end
    end
  end
end
```

This looks like a lot, but it's mostly just simple configuration. We are utilizing `ActiveSupport::Concern` here to inject some behavior into our `Grape::API` classes that mix this in. In our `included` block, we set up things like the prefix, the version (noting that it is in the path and not the headers), some default formatting, a few nicety methods for permitted params/logging and rescues for handling errors.

Including this file will make mounting more and more API endpoints much easier. Default behavior can be centralized to a single spot.

## Auto-Documentation

Swagger, the documentation generator, needs a few configuration changes at our Rails app's initialization. Edit `config/initializers/grape.rb`...

```ruby
GrapeSwaggerRails.options.url = "/api/v1/swagger_doc.json"
GrapeSwaggerRails.options.app_name = "Biznz"
GrapeSwaggerRails.options.app_url = "http://localhost:3000"
```

## Try It Out

For good measure, restart your `bundle exec rails server`.

You should now be able to point your favorite web browser at `http://localhost:3000/documentation` and see some documentation that Swagger generated (with Grape's DSL) for *free*. Click the `contacts` link to show the API endpoints. Now, click on each of the two endpoints we created before.

Wow.

Now, your mobile team can stop hassling you to update your API design docs. Just give them a URL and tell them to cool it. If you tried to make a request with the Swagger tool, you might realize you need some data now. We'll get to that.

## Testing

First, let's write some specs, get a factory started and add some validations to our model. Need some example specs? Check out my Gist on [The Greatest Hits of RSpec: Volume 1](https://gist.github.com/tonycoco/8798536). After that, open the spec `spec/models/contact_spec.rb`...

```ruby
require "spec_helper"

describe Contact do
  it "should have a factory" do
    expect(FactoryGirl.build(:contact)).to be_valid
  end

  context "validations" do
    it { should validate_uniqueness_of(:email) }
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:title) }
  end
end
```

Okay, so we've got a few things here. I'm using the `shouldda-matchers` gem for some of the validation specs. If you haven't seen those matchers in Rspec, [take a look here](https://github.com/thoughtbot/shoulda-matchers). This is a good start. Let's run those specs...

    bundle exec rake

Fail.

That's exactly what we want. Let's fill in the gaps to get some passing specs. Open `app/models/contact.rb`...

```ruby
class Contact < ActiveRecord::Base
  validates :email, uniqueness: true
  validates :first_name, :last_name, :email, :title, presence: true
end
```

Sure, we have a factory that will work, but I want some good old fashioned fake data using `Faker`. Open `specs/factories/contacts.rb`...

```ruby
FactoryGirl.define do
  factory :contact do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    email { Faker::Internet.email }
    title { Faker::Name.title }
  end
end
```

To clean up the spec runner, let's remove that pesky `AdminUser`'s generated spec file...

    rm spec/models/admin_user_spec.rb

Now, run the specs...

    bundle exec rake

Beautifully green... I hope.

## B.S.

Getting that fake data into our API application is easy...

    bundle exec rails console

Now issue some commands to Rails...

    FactoryGirl.create_list(:contact, 10)

That should give us 10 fake contacts. Just like my Rolodex, am I right?

Terrible jokes aside, this is all we need to start building our Ember.js application front-end to fetch a few contacts.

## It's Working!

Test out our endpoints now and fetch the JSON representation of those 10 contacts we just created. Go to `http://localhost:3000/documentation`, click on the contacts link, click on the `GET /api/v1/contacts` link and click the `Try it out!` button.

Alternatively, you can just hit the API directly at `http://localhost:3000/api/v1/contacts`.

## Moving On

You're now ready for [Part 2: The Front-End](PART_2.md).
