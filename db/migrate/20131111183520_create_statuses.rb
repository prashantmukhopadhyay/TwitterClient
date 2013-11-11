class CreateStatuses < ActiveRecord::Migration
  def change
    create_table :statuses do |t|
      t.string :twitter_status_id, null: false
      t.string :body, null: false
      t.string :twitter_user_id, null: false

      t.timestamps
    end

    add_index :statuses, :twitter_status_id, unique: true
    add_index :statuses, :twitter_user_id, unique: true
  end
end
