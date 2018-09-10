class AddMoodIdToMoods < ActiveRecord::Migration[5.2]
  def change
    add_column :moods, :mood_list_id, :integer
  end
end
