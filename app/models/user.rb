class User < ActiveRecord::Base
  attr_accessible :screen_name, :twitter_user_id

  validates :screen_name, :twitter_user_id, presence: true
  validates :twitter_user_id, uniqueness: true
end
