# Use active_model_serializers gem to create serializer for Post model
# Define what attributes of a post are exposed in the JSON API

create_file 'app/serializers/post_serializer.rb', <<~RUBY
class PostSerializer < ActiveModel::Serializer
  attributes :id, :title, :subtitle, :published_at, :image_url, :slug, :keywords, :content, :created_at, :updated_at

  # Include associated admin and category data
  # This assumes you have AdminSerializer and CategorySerializer if you want nested objects.
  belongs_to :admin
  belongs_to :category

  # Custom attribute for rich text content
  # Action Text content is stored in a separate model, so we explicitly serialize it.
  attribute :content do |object|
    object.content.body.to_html if object.content.present?
  end
end
RUBY

# You'll also need serializers for Admin and Category if you want them nested
say "#{INDENT}Creating AdminSerializer...", :blue
create_file 'app/serializers/admin_serializer.rb', <<~RUBY
class AdminSerializer < ActiveModel::Serializer
  attributes :id, :email, :name, :title, :bio, :profile_picture_url, :social_media_links
  # Do NOT include sensitive attributes like :encrypted_password here!
end
RUBY

say "#{INDENT}Creating CategorySerializer...", :blue
create_file 'app/serializers/category_serializer.rb', <<~RUBY
class CategorySerializer < ActiveModel::Serializer
  attributes :id, :category_name, :category_description
end
RUBY
