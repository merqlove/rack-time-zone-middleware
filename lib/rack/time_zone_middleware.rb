require 'rack/time-zone-middleware/version'
require 'active_support/values/time_zone'

module Rack
  class TimeZoneMiddleware
    DEFAULT_TIME_ZONE    = 'Europe/Moscow'
    DEFAULT_AS_TIME_ZONE = 'Moscow'
    DEFAULT_KEY          = 'dummy.time_zone'

    attr_reader :app, :runner, :options

    def initialize(app, opts = {}, &block)
      @app = app

      @options = {}
      options[:default_tz]    = opts.fetch(:default_tz, DEFAULT_TIME_ZONE)
      options[:default_as_tz] = opts.fetch(:default_as_tz, DEFAULT_AS_TIME_ZONE)
      options[:default_key]   = opts.fetch(:default_key, DEFAULT_KEY)

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
      zone_name, _ = ::ActiveSupport::TimeZone::MAPPING.detect { |_, v| v.eql? name }
      zone_name || options[:default_as_tz]
    end

    private

    def _call(mw, env)
      request = ::Rack::Request.new(env)

      time_zone = request.cookies[mw.options[:default_key]] || mw.options[:default_tz]
      env[mw.options[:default_key]] = mw.find_as_time_zone(time_zone)

      mw.app.call(env)
    end
  end
end
