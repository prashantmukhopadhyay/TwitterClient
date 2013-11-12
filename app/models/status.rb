class Status < ActiveRecord::Base
  attr_accessible :body, :twitter_status_id, :twitter_user_id

  validates :body, :twitter_status_id, :twitter_user_id, presence: true
  validates :twitter_status_id, uniqueness: true

  belongs_to(
    :author,
    class_name: 'User',
    foreign_key: :twitter_user_id,
    primary_key: :twitter_user_id
  )

  def self.fetch_statuses_for_user(user)
    url = Addressable::URI.new(
    scheme: 'https',
    host: 'api.twitter.com',
    path: '/1.1/statuses/user_timeline.json',
    query_values: { user_id: user.twitter_user_id }
    ).to_s

    json_str = TwitterSession.get(url).body

    parse_twitter_params(json_str)
  end

  def self.parse_twitter_params(json_str)

    results = JSON.parse(json_str)

    results.map do |tweet|
      tweet_id_str = tweet["id_str"]
      body = tweet["text"]
      user_id = tweet["user"]["id_str"]

      if Status.where(twitter_status_id: tweet_id_str).exists?
        Status.find_by_twitter_status_id(tweet_id_str)
      else
        Status.new(twitter_status_id: tweet_id_str, twitter_user_id: user_id, body: body)
      end
    end
  end

  def self.post(text)
    url = Addressable::URI.new(
    scheme: 'https',
    host: 'api.twitter.com',
    path: '/1.1/statuses/update.json',
    query_values: { status: text }
    ).to_s

    json_str = TwitterSession.post(url).body
    results = JSON.parse(json_str)

    p results
    tweet_id_str = results["id_str"]
    body = results["text"]
    user_id = results["user"]["id_str"]

    Status.create(twitter_status_id: tweet_id_str, twitter_user_id: user_id, body: body)

  end

end
