class AddPlaylistUriToMoods < ActiveRecord::Migration[5.2]
  def change
    add_column :moods, :playlist_uri, :string
  end
end
