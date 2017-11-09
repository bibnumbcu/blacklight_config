# -*- encoding : utf-8 -*-
class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.integer :user_id, :null=>false
    end
 
  end

  def self.down
    drop_table :users
  end
  
end
