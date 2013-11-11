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
end
