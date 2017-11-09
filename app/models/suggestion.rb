class Suggestion < ActiveRecord::Base
  attr_accessible :book_id, :user_id, :recipient if Rails::VERSION::MAJOR < 4
  belongs_to :book
  belongs_to :user

end
