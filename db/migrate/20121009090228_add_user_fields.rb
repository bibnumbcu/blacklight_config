class AddUserFields < ActiveRecord::Migration
  def up
    add_column :users, :name, :string
    add_column :users, :first_name, :string
    add_column :users, :email, :string
  end

  def down
    remove_column :users, :name
    remove_column :users, :first_name
    remove_column :users, :email
  end
end
