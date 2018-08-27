class AddProfileImageToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :profile_image, :string
    add_column :users, :display_name, :string
  end
end
