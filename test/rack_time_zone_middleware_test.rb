require 'coveralls'
Coveralls.wear!

require 'minitest/autorun'
require 'rack/mock'
require 'rack/time-zone-middleware'
require 'active_support/concern'

describe 'Rack::TimeZoneMiddleware' do
  module TestCall
    extend ActiveSupport::Concern

    included do
      it 'setting Moscow when nil' do
        check_time_zone(nil, 'Moscow')
      end

      it 'setting Moscow' do
        check_time_zone('Europe/Moscow', 'Moscow')
      end

      it 'setting Paris' do
        check_time_zone('Europe/Paris', 'Paris')
      end

      it 'setting Eastern Time (US & Canada)' do
        check_time_zone('America/New_York', 'Eastern Time (US & Canada)')
      end

      it 'setting Moscow when nil on custom key' do
        check_time_zone(nil, 'Moscow', 'some.time_zone')
      end

      it 'setting Moscow on custom key' do
        check_time_zone('Europe/Moscow', 'Moscow', 'some.time_zone')
      end

      it 'setting Paris on custom key' do
        check_time_zone('Europe/Paris', 'Paris', 'some.time_zone')
      end

      it 'setting Eastern Time (US & Canada) on custom key' do
        check_time_zone('America/New_York', 'Eastern Time (US & Canada)', 'some.time_zone')
      end
    end
  end

  let(:app) do
    lambda { |env| [200, {'Content-Type' => 'text/plain'}, Rack::Request.new(env)] }
  end

  describe '#find_as_time_zone' do
    subject { Rack::TimeZoneMiddleware.new(app) }

    it 'Copenhagen' do
      expect(subject.find_as_time_zone('Europe/Copenhagen')).must_equal 'Copenhagen'
    end

    it 'Paris' do
      expect(subject.find_as_time_zone('Europe/Paris')).must_equal 'Paris'
    end

    it 'Moscow' do
      expect(subject.find_as_time_zone('Europe/Moscow')).must_equal 'Moscow'
    end

    it 'Stockholm' do
      expect(subject.find_as_time_zone('Europe/Stockholm')).must_equal 'Stockholm'
    end

    it 'Tashkent' do
      expect(subject.find_as_time_zone('Asia/Tashkent')).must_equal 'Tashkent'
    end

    it 'Hong Kong' do
      expect(subject.find_as_time_zone('Asia/Hong_Kong')).must_equal 'Hong Kong'
    end

    it 'Kamchatka' do
      expect(subject.find_as_time_zone('Asia/Kamchatka')).must_equal 'Kamchatka'
    end

    it 'Canberra' do
      expect(subject.find_as_time_zone('Australia/Melbourne')).must_equal 'Canberra'
    end

    it 'America/Chicago' do
      expect(subject.find_as_time_zone('America/Chicago')).must_equal 'Central Time (US & Canada)'
    end
  end

  describe '#call' do
    describe 'plain call' do
      include TestCall

      def request_for_request_with_cookies(cookie_time_zone, key='dummy.time_zone')
        env = Rack::MockRequest.env_for('/')
        env['HTTP_COOKIE'] = "#{key}=#{cookie_time_zone}"
        Rack::TimeZoneMiddleware.new(app, default_key: key).call(env).last
      end
    end

    describe 'block call' do
      include TestCall

      def request_for_request_with_cookies(cookie_time_zone, key='dummy.time_zone')
        env = Rack::MockRequest.env_for('/')
        env['HTTP_COOKIE'] = "#{key}=#{cookie_time_zone}"
        Rack::TimeZoneMiddleware.new(app) do |mw, _env|
          request = ::Rack::Request.new(_env)

          time_zone = request.cookies[key] || mw.options[:default_tz]
          _env[key] = mw.find_as_time_zone(time_zone)

          mw.app.call(_env)
        end.call(env).last
      end
    end

    describe 'settings call' do
      it 'setting Paris when nil' do
        check_time_zone(nil, 'Paris')
      end

      it 'setting Moscow' do
        check_time_zone('Europe/Moscow', 'Moscow')
      end

      it 'setting Paris' do
        check_time_zone('Europe/Paris', 'Paris')
      end

      it 'setting Eastern Time (US & Canada)' do
        check_time_zone('America/New_York', 'Eastern Time (US & Canada)')
      end

      it 'setting Paris when nil on custom key' do
        check_time_zone(nil, 'Paris', 'some.time_zone')
      end

      it 'setting Moscow on custom key' do
        check_time_zone('Europe/Moscow', 'Moscow', 'some.time_zone')
      end

      it 'setting Paris on custom key' do
        check_time_zone('Europe/Paris', 'Paris', 'some.time_zone')
      end

      it 'setting Eastern Time (US & Canada) on custom key' do
        check_time_zone('America/New_York', 'Eastern Time (US & Canada)', 'some.time_zone')
      end

      def request_for_request_with_cookies(cookie_time_zone, key='dummy.time_zone')
        env = Rack::MockRequest.env_for('/')
        env['HTTP_COOKIE'] = "#{key}=#{cookie_time_zone}"
        Rack::TimeZoneMiddleware.new(app, default_tz: 'Europe/Paris', default_as_tz: 'Paris', default_key: key).call(env).last
      end
    end
  end

  def request_for_request_with_cookies(_, __); Struct.new(:env) end

  def check_time_zone(cookie_time_zone, time_zone, key='dummy.time_zone')
    request = request_for_request_with_cookies(cookie_time_zone, key)
    expect(request.env).must_include key
    expect(request.env[key]).must_equal time_zone
  end
end
