class Book < ActiveRecord::Base
  
  validates_presence_of :title, :isbn
  validates_format_of :isbn, :with => /(\d[- ]?){9,9}([0-9xX])/
  
  has_and_belongs_to_many :authors
  belongs_to :publisher

  belongs_to :categorization
  has_many :categories, :through => :categorizations  
  
  acts_as_dropdown
      
end
