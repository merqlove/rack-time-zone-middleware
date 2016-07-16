require 'rack/time-zone-middleware/version'

module Rack
  class TimeZoneMiddleware
    DEFAULT_TIME_ZONE    = 'Europe/Moscow'
    DEFAULT_AS_TIME_ZONE = 'Moscow'
    DEFAULT_KEY          = 'dummy.time_zone'
    DEFAULT_COOKIE_KEY   =  DEFAULT_KEY

    MAP_WARNING = "Please install `activesupport` gem and `require 'active_support/values/time_zone'` or provide custom TimeZone map, as a `Hash` like `{'Moscow' => 'Europe/Moscow'}`"

    attr_reader :app, :runner, :options

    def initialize(app, opts = {}, &block)
      @app = app

      @options = {}
      options[:default_tz]    = opts.fetch(:default_tz, DEFAULT_TIME_ZONE)
      options[:default_as_tz] = opts.fetch(:default_as_tz, DEFAULT_AS_TIME_ZONE)
      options[:time_zone_key] = opts.fetch(:time_zone_key, DEFAULT_KEY)
      options[:cookie_key]    = opts.fetch(:cookie_key, DEFAULT_COOKIE_KEY)

      @time_zone_map = opts.fetch(:time_zone_map, nil) || default_time_zone_map

      if block_given?
        @runner = block
      else
        @runner = ->(mw, env) { _call(mw, env) }
      end
    end

    def call(env)
      runner.call(self, env)
    end

    def find_as_time_zone(name)
      zone_name, _ = time_zone_map.detect { |_, v| v.eql? name }
      zone_name || options[:default_as_tz]
    rescue
      options[:default_as_tz]
    end

    private

    def time_zone_map
      @time_zone_map.is_a?(Proc) ? @time_zone_map.call : @time_zone_map
    end

    def default_time_zone_map(no_test=true)
      if no_test && defined?(::ActiveSupport::TimeZone::MAPPING)
        -> { ::ActiveSupport::TimeZone::MAPPING }
      else
        $stderr.puts MAP_WARNING
        -> { {} }
      end
    end

    def _call(mw, env)
      request = ::Rack::Request.new(env)

      time_zone = request.cookies[mw.options[:cookie_key]] || mw.options[:default_tz]
      env[mw.options[:time_zone_key]] = mw.find_as_time_zone(time_zone)

      mw.app.call(env)
    end
  end
end
