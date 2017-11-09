class Book < ActiveRecord::Base
  attr_accessible :title, :author, :publisher, :pub_date, :isbn, :note if Rails::VERSION::MAJOR < 4
  validates :title, :publisher, :pub_date, presence: true
  has_many :suggestions, dependent: :restrict_with_error
  
  
  
end
