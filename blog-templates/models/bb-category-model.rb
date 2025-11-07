# Build out category model
inject_into_file "app/models/category.rb", after: "class Category < ApplicationRecord\n" do <<~RUBY
  has_many :post_categories, dependent: :destroy
  has_many :posts, through: :post_categories

  validates :category_name, presence: true, uniqueness: { case_sensitive: false }
RUBY
end
