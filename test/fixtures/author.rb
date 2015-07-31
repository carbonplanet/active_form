class Author < ActiveRecord::Base
  
  has_and_belongs_to_many :books

  acts_as_dropdown
  
  def name
    "#{first_name} #{last_name}"
  end
  
end
