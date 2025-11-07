# Add basic routes and safe controller actions for minimal working state
# Use apply from Thor to use in template.

say "#{INDENT}Setting up basic routes...", :blue

# Add post resource routes
inject_into_file 'config/routes.rb', after: "Rails.application.routes.draw do\n" do <<~RUBY
  # Public blog routes
  resources :posts, only: [:index, :show]

RUBY
end

# Create a safe minimal version of the posts controller that won't crash
say "#{INDENT}Creating safe Posts controller actions...", :blue

# Replace the existing controller file with a minimal safe version
remove_file 'app/controllers/posts_controller.rb'
create_file 'app/controllers/posts_controller.rb', <<~RUBY
class PostsController < ApplicationController
  def index
    @featured_post = Post.find_by(featured: true)

    if @featured_post
      @posts = Post.where.not(id: @featured_post.id).published.sorted
    else
      @posts = Post.published.sorted # All published posts if no featured one
    end
    @categories = Category.order(:category_name)
  end

  def show
    # Safe minimal version
    if Post.table_exists?
      @post = Post.find(params[:id])
    else
      redirect_to root_path, alert: "Post not found"
    end
  end
end
RUBY

say "#{INDENT}✅ Basic routes and safe controller configured", :green
