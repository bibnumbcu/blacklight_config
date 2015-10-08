class Book < ActiveRecord::Base
  attr_accessible :title, :author, :publisher, :pub_date, :isbn, :note
  validates :title, :publisher, :pub_date, presence: true
  has_many :suggestions, dependent: :restrict
  
  
  
end
