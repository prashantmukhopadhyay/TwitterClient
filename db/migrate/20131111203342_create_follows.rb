class CreateFollows < ActiveRecord::Migration
  def change
    create_table :follows do |t|
      t.string :twitter_follower_id, null: false
      t.string :twitter_followee_id, null: false

      t.timestamps
    end

    add_index :follows, :twitter_follower_id, unique: true
    add_index :follows, :twitter_followee_id, unique: true
  end
end
