# Mongoid::Followit [![Build Status](https://travis-ci.org/lucasmedeirosleite/mongoid-followit.svg)](https://travis-ci.org/lucasmedeirosleite/mongoid-followit) [![Code Climate](https://codeclimate.com/github/lucasmedeirosleite/mongoid-followit/badges/gpa.svg)](https://codeclimate.com/github/lucasmedeirosleite/mongoid-followit) [![Test Coverage](https://codeclimate.com/github/lucasmedeirosleite/mongoid-followit/badges/coverage.svg)](https://codeclimate.com/github/lucasmedeirosleite/mongoid-followit/coverage)

Add social capabilities to your models.

### Prerequisites

 * Ruby >= 2.1
 * Mongoid >= 4.0

### Installation

Add this line to your application's Gemfile:

```ruby
gem 'mongoid_followit'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mongoid_followit

### Usage

Take as an example the following model: 

```ruby
  class Person
    include Mongoid::Document
   
    field :name, type: String
  end
```
When including the module ``` Mongoid::Followit::Follower ```

The model starts working like this:

```
=> jedi = Profile.create(name: 'Jedi')
=> padawan = Profile.create(name: '')
=> person = Person.create(name: 'Obi Wan')
=> person.follow(jedi, padawan)
=> person.unfollow(padawan)
=> person.followees
```

The model to be followed MUST include the ```Mongoid::Followit::Followee``` module

```ruby
  class Profile
    include Mongoid::Document
    include Mongoid::Followit::Followee
   
    field :name, type: String
  end
```

And the followee model starts working like this:

```
=> jedi.followers
```

### Callbacks

Every model that includes ```Mongoid::Followit::Follower``` can define callbacks for the #follow and #unfollow methods:

```ruby
  class MyModel
    include Mongoid::Document
    include Mongoid::Followit::Follower

    before_follow   :do_something_before
    before_unfollow :do_otherthing_before

    after_follow   :do_something_after
    after_unfollow :do_otherthing_after
  end
```

### TODO

Add more queryable methods. 

### Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

### Contributing

Bug reports and pull requests are welcome on GitHub at [this repository](https://github.com/lucasmedeirosleite/mongoid_followit). This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

### License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).