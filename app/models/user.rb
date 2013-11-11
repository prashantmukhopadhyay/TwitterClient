class User < ActiveRecord::Base
  attr_accessible :screen_name, :twitter_user_id

  validates :screen_name, :twitter_user_id, presence: true
  validates :screen_name, :twitter_user_id, uniqueness: true

  has_many(
    :statuses,
    class_name: 'Status',
    foreign_key: :twitter_user_id,
    primary_key: :twitter_user_id
  )

  has_many(
    :inbound_follows,
    class_name: 'Follow',
    foreign_key: :twitter_followee_id,
    primary_key: :twitter_user_id
  )

  has_many(
    :outbound_follows,
    class_name: 'Follow',
    foreign_key: :twitter_follower_id,
    primary_key: :twitter_user_id
  )

  has_many :followers, through: :inbound_follows, source: :follower
  has_many :followed_users, through: :outbound_follows, source: :followee

  def self.fetch_by_screen_name(screen_name)
    url = Addressable::URI.new(
      scheme: 'https',
      host: 'api.twitter.com',
      path: '/1.1/users/show.json',
      query_values: { screen_name: screen_name }
    ).to_s

    json_str = TwitterSession.get(url).body

    parse_twitter_params(json_str)
  end

  def self.parse_twitter_params(json_str)

    results = JSON.parse(json_str)
    id_str = results["id_str"]

    screen_name = results["screen_name"]

    if User.where(twitter_user_id: id_str).exists?
      User.find_by_twitter_user_id(id_str)
    else
      User.new(screen_name: screen_name, twitter_user_id: id_str)
    end
  end

  def self.fetch_by_ids(twitter_user_ids)
    existing_users = []
    ids_to_fetch = []

    twitter_user_ids.each do |twitter_user_id|
      if User.where(twitter_user_id: twitter_user_id).exists?
        existing_users << User.find_by_twitter_user_id(twitter_user_id)
      else
        ids_to_fetch << twitter_user_id
      end
    end

    return existing_users if ids_to_fetch.empty?

    url = Addressable::URI.new(
      scheme: 'https',
      host: 'api.twitter.com',
      path: '/1.1/users/lookup.json',
      query_values: { user_id: ids_to_fetch.join(',') }
    ).to_s

    json_str = TwitterSession.get(url).body
    results = JSON.parse(json_str)

    fetched_users = results.map do |user|
      id_str = user["id_str"]
      screen_name = user["screen_name"]

      User.new(screen_name: screen_name, twitter_user_id: id_str)
    end

    existing_users + fetched_users
  end

  def sync_statuses
    statuses = Status.fetch_statuses_for_user(self)
    statuses.each do |tweet|
     tweet.save! unless tweet.persisted?
    end
  end

  def fetch_followers
    url = Addressable::URI.new(
      scheme: 'https',
      host: 'api.twitter.com',
      path: '/1.1/followers/ids.json',
      query_values: { user_id: self.twitter_user_id, stringify_ids: true }
    ).to_s

    json_str = TwitterSession.get(url).body
    results = JSON.parse(json_str)

    follower_ids = results["ids"]

    self.class.fetch_by_ids(follower_ids)
  end

  def sync_followers
    fetched_followers = self.fetch_followers
    fetched_followers.each do |follower|
     follower.save! unless follower.persisted?
    end

    self.followers= fetched_followers
  end
end
