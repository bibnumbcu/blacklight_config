class CreateSuggestions < ActiveRecord::Migration
  def self.up
    create_table :suggestions do |t|
      t.integer :user_id, null: false
      t.integer :book_id, null: false
      t.integer :status, null: false
      t.string :recipient, null: false
      t.timestamps
    end
    add_index :suggestions, :user_id
    add_index :suggestions, :book_id
  end
  
  def self.down
    drop_table :suggestions
  end
end
