class CreateSocialPlatform < ActiveRecord::Migration[8.0]
  def change
    create_table :social_platforms do |t|
      t.string :ig_id
      t.string :ig_link
      t.string :youtube_id
      t.string :youtube_link
      t.string :ig_followers
      t.string :youtube_subscriber
      t.string :twitter_id
      t.string :twitter_followers
      t.string :twitter_link
      t.references :profile, null: false, foreign_key: true

      t.timestamps
    end
  end
end
