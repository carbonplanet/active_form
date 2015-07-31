class Category < ActiveRecord::Base
  
  belongs_to :categorization
  has_many :books, :through => :categorization
  
  acts_as_dropdown
    
end
