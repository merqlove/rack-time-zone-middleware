# Rack::TimeZoneMiddleware

[![Gem Version](https://badge.fury.io/rb/rack-time-zone-middleware.svg)](https://badge.fury.io/rb/rack-time-zone-middleware)
[![Build Status](https://travis-ci.org/merqlove/rack-time-zone-middleware.svg?branch=master)](https://travis-ci.org/merqlove/rack-time-zone-middleware)
[![Coverage Status](https://coveralls.io/repos/github/merqlove/rack-time-zone-middleware/badge.svg?branch=master)](https://coveralls.io/github/merqlove/rack-time-zone-middleware?branch=master)
[![Code Climate](https://codeclimate.com/github/merqlove/rack-time-zone-middleware/badges/gpa.svg)](https://codeclimate.com/github/merqlove/rack-time-zone-middleware)

Adding ability to detect timezone at UI side and get it within Rack/Rails via cookies with/o custom handler.

This gem created for usecase of loading detected TimeZone into Rails environment.  
You can set cookie with TimeZone name at UI side(from Angular, React, Ember, Backbone or vanilla JS).  
After that all XHR requests to your Rails/Rack backend can be identified by this Middleware.  
In case when TimeZone name(s) is unsupported or key not found in cookies, middleware will fallback to defaults.  
By default we are using [ActiveSupport TimeZones](https://github.com/rails/rails/blob/master/activesupport/lib/active_support/values/time_zone.rb#L30), if AS is not installed and you haven't provided someone else, you will got empty `TimeZone` hash with Warning message.  
So we have no dependency on `ActiveSupport`, but we'd like to use it.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rack-time-zone-middleware'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rack-time-zone-middleware

## Logic in detail

1. UI
    1. Use something like [JsTz](http://pellepim.bitbucket.org/jstz/) to determine users time-zone. 
    2. Write time-zone name to cookie.
    3. [AngularJS Example](#angularjs)
2. Ruby
    1. Use one of loading ways explained below ([Usage](#usage)).
    2. Provide cookie `key_name` with options, wich includes detected time-zone.
    3. Provide enironment `key_name` with options, where you store its value.
    4. Use `env['key_name']` to access saved value from your application or controller.
  
## Usage

### Sinatra/Padrino application

```ruby
require 'rack/time-zone-middleware'

# Default TimeZone handler.
use Rack::TimeZoneMiddleware

# Configured TimeZone handler.
use Rack::TimeZoneMiddleware, default_tz: 'Europe/Moscow', 
                              default_as_tz: 'Moscow', 
                              time_zone_key: 'dummy.time_zone'
                              cookie_key: 'dummy.time_zone'

# Your own TimeZone handler. All options & instance methods is available through middleware parameter.
use Rack::TimeZoneMiddleware do |middleware, env|
  request = ::Rack::Request.new(env)
    
  time_zone = request&.cookies['dummy.time_zone'] || middleware.options[:default_tz]
  env['dummy.time_zone'] = middleware.find_as_time_zone(time_zone)
  
  middleware.app.call(env)    
end
```

### Rails application

```ruby
# Default TimeZone handler.
config.middleware.use Rack::TimeZoneMiddleware

# Configured TimeZone handler.
config.middleware.use Rack::TimeZoneMiddleware, default_tz: 'Europe/Moscow', 
                                                default_as_tz: 'Moscow', 
                                                time_zone_key: 'dummy.time_zone'
                                                cookie_key: 'dummy.time_zone'

# Your own TimeZone handler. All options & instance methods is available through middleware parameter.
config.middleware.use Rack::TimeZoneMiddleware do |middleware, env|
  request = ::Rack::Request.new(env)
    
  time_zone = request&.cookies['dummy.time_zone'] || middleware.options[:default_tz]
  env['dummy.time_zone'] = middleware.find_as_time_zone(time_zone)
  
  middleware.app.call(env)    
end
```

In theory you can setup dynamic TimeZones detector(when its hash is managed from your Application, from Admin panel or something),  
but in most of realizations what i saw, it is overhead.

### Options

| name  | description |
|---|---|
| default_tz | `optional`, TimeZone name fallback value (default: 'Europe/Moscow') |
| default_as_tz | `optional`, `ActiveSupport::TimeZone` key name fallback value (default: 'Moscow') |
| cookie_key | `optional`, Cookie key name (default: 'dummy.time_zone') |
| time_zone_key | `optional`, Environment key name (default: 'dummy.time_zone') |
| time_zone_map | `optional`, TimeZone `Hash` or `lambda`, like `{'Moscow' => 'Europe/Moscow'}`. If not provided `ActiveSupport` TZInfo map will be tried. |

## AngularJS

TimeZone updater factory example via [JsTz](http://pellepim.bitbucket.org/jstz/)

```javascript
web.services.factory('JsTz', ['ipCookie', function(ipCookie) {
  return {
    updateCookie: function() {
      tz = jstz.determine();
      name = tz.name(); 
      ipCookie('dummy.time_zone', name, { path: '/', expires: 21 });
      return name;
    }
  };  
}]);
```

## Dependencies:

- [Rack](https://github.com/rack/rack)
- [ActiveSupport(optional)](https://github.com/rails/rails)

## Contributing

1. Fork it ( https://github.com/merqlove/rack-time-zone-middleware/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

Bug reports and pull requests are welcome on GitHub at https://github.com/merqlove/rack-time-zone-middleware.

### Testing

    $ rake test 

## Development

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

Copyright (c) 2016 Alexander Merkulov

MIT License
