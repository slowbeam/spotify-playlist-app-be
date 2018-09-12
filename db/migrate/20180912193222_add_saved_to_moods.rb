class AddSavedToMoods < ActiveRecord::Migration[5.2]
  def change
    add_column :moods, :saved, :boolean
  end
end
