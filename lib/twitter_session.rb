require 'singleton'
require 'oauth'
require 'yaml'

class TwitterSession
  include Singleton

  CONSUMER_KEY = 'XBEbjeKMYxPs7Bvw5CSrEA'
  CONSUMER_SECRET = 'awCpHQXnODpBRtSIEyAzEiov9q876hjPCpbQrabnEIk'

  CONSUMER = OAuth::Consumer.new(
    CONSUMER_KEY, CONSUMER_SECRET, :site => "https://twitter.com")

  attr_reader :access_token

  def initialize
    @access_token = read_or_request_access_token
  end

  def self.get(*args)
    self.instance.access_token.get(*args)
  end

  def self.post(*args)
    self.instance.access_token.post(*args)
  end

  protected
  def read_or_request_access_token
    token_file = 'token_file.token'

    if File.exist?(token_file)
      File.open(token_file) { |f| YAML.load(f) }
    else
      access_token = request_access_token
      File.open(token_file, 'w') { |f| YAML.dump(access_token, f) }

      access_token
    end
  end

  def request_access_token
  end
end