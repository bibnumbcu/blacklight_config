class Suggestion < ActiveRecord::Base
  attr_accessible :book_id, :user_id, :recipient
  belongs_to :book
  belongs_to :user, :class_name => "User", foreign_key: "user_id"

end
