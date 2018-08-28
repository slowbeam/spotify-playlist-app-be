class RemovePopularityFromSongs < ActiveRecord::Migration[5.2]
  def change
    remove_column :songs, :popularity
    remove_column :songs, :danceability
    remove_column :songs, :energy
    remove_column :songs, :key
    remove_column :songs, :loudness
    remove_column :songs, :instrumentalness
    remove_column :songs, :valence
    remove_column :songs, :tempo
  end
end
