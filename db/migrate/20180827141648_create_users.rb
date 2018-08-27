class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :spotify_url
      t.string :href
      t.string :uri
      t.string :access_token
      t.string :refresh_token
      t.boolean :logged_in

      t.timestamps
    end
  end
end
