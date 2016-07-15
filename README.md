# Rack::TimeZoneMiddleware

Adding ability to detect timezone at UI side and get it within Rack/Rails via cookies with/o custom handler.

This gem created for usecase of loading predefined TimeZone into Rails environment.  
You can set cookie with TimeZone name at UI side(from Angular, React, Ember, Backbone or vanilla JS).  
After that all XHR requests to your Rails/Rack backend will be fetched with this Middleware. 

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rack-time-zone-middleware'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rack-time-zone-middleware

## Usage

### Sinatra/Padrino application

```ruby
require 'rack/time-zone-middleware'

# Default TimeZone handler.
use Rack::TimeZoneMiddleware

# Configured TimeZone handler.
use Rack::TimeZoneMiddleware default_tz: 'Europe/Moscow', default_as_tz: 'Moscow', default_key: 'dummy.time_zone'

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
config.middleware.use Rack::TimeZoneMiddleware default_tz: 'Europe/Moscow', default_as_tz: 'Moscow', default_key: 'dummy.time_zone'

# Your own TimeZone handler. All options & instance methods is available through middleware parameter.
config.middleware.use Rack::TimeZoneMiddleware do |middleware, env|
  request = ::Rack::Request.new(env)
    
  time_zone = request&.cookies['dummy.time_zone'] || middleware.options[:default_tz]
  env['dummy.time_zone'] = middleware.find_as_time_zone(time_zone)
  
  middleware.app.call(env)    
end
```

### Options

| name  | description |
|---|---|
| default_tz | Default TimeZone for fallback(default: 'Europe/Moscow') |
| default_as_tz | Default `ActiveSupport::TimeZone` fallback key(default: 'Moscow') |
| default_key | Default cookie and environment keys(default: 'dummy.time_zone') |

## Dependencies:

- [Rack](https://github.com/rack/rack)
- [ActiveSupport](https://github.com/rails/rails)

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
