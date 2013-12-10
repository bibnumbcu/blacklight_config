class ChangeUserIdType < ActiveRecord::Migration
  def up
	change_column :users, :user_id, :string, :null=>false
  end

  def down
  end
end
