class CreateSongs < ActiveRecord::Migration[5.2]
  def change
    create_table :songs do |t|
      t.string :title
      t.string :artist
      t.string :album_cover
      t.string :release_date
      t.string :uri
      t.integer :popularity
      t.string :spotify_id
      t.float :danceability
      t.float :energy
      t.integer :key
      t.float :loudness
      t.float :instrumentalness
      t.float :valence
      t.float :tempo
      t.timestamps
    end
  end
end
