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
      Status.new(twitter_status_id: tweet_id_str, twitter_user_id: user_id, body: body)
    end
  end
end
