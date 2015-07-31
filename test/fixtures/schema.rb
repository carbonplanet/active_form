ActiveRecord::Schema.define(:version => 1) do

  create_table "authors", :force => true do |t|
    t.column "first_name", :string
    t.column "last_name", :string
    t.column "birth_date", :date
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
  end

  create_table "authors_books", :force => true do |t|
    t.column "author_id", :integer
    t.column "book_id", :integer
  end

  create_table "books", :force => true do |t|
    t.column "title", :string
    t.column "isbn", :string
    t.column "publication_date", :date
    t.column "publisher_id", :integer, :default => 1
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
  end

  create_table "categories", :force => true do |t|
    t.column "name", :string, :limit => 64
    t.column "description", :string
  end

  create_table "categorizations", :force => true do |t|
    t.column "category_id", :integer
    t.column "book_id", :integer
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
  end

  create_table "publishers", :force => true do |t|
    t.column "name", :string
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
  end

end