class AddSadListUriToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :sadlist_uri, :string
    add_column :users, :contentlist_uri, :string
    add_column :users, :ecstaticlist_uri, :string
  end
end
