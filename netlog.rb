#!/usr/bin/env ruby
require 'rubygems'
require 'sinatra'
require 'oauth'

module Netlog
  class Client
    def initialize(options = {})
      @consumer_key = options[:consumer_key]
      @consumer_secret = options[:consumer_secret]
      @token = options[:token]
      @secret = options[:secret]
    end

    def request_token(options={})
      consumer.get_request_token(options)
    end

    protected
    def consumer
      @consumer ||= OAuth::Consumer.new(
          @consumer_key,
          @consumer_secret,
          { :site=>"http://en.netlog.com" }
      )
    end

    def access_token
      @access_token ||= OAuth::AccessToken.new(consumer, @token, @secret)
    end
  end
end

configure do
  set :sessions, true
  @@config = YAML.load_file("config.yml") rescue nil || {}
end

before do
  @client = Netlog::Client.new(
    :consumer_key => @@config['consumer_key'],
    :consumer_secret => @@config['consumer_secret'],
    :token => session[:access_token],
    :secret => session[:secret_token]
  )
end

get '/' do
  erb :home
end

get '/connect' do
  callback_url = "http://#{Sinatra::Application.host}:#{Sinatra::Application.port}/callback"
  request_token = @client.request_token(:oauth_callback => callback_url)
  session[:request_token] = request_token.token
  session[:request_token_secret] = request_token.secret
  redirect request_token.authorize_url
end

get '/callback' do
  'If you can read this, then the bug did not occur.'
end