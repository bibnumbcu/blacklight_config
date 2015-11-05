class CreateBooks < ActiveRecord::Migration
  def self.up
    create_table :books do |t|
      t.string :title, null: false
      t.string :author, null: false
      t.string :publisher, null: false
      t.string :isbn
      t.string :pub_date
      t.text :note
      t.timestamps
    end
  end
  
  def self.down
    drop_table :books
  end
end
