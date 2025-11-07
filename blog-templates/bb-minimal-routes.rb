# Add basic routes for minimal working state
# Use apply from Thor to use in template.

say "#{INDENT}Setting up basic routes...", :blue

# Add root route pointing to posts#index (public blog controller)
inject_into_file 'config/routes.rb', after: "Rails.application.routes.draw do\n" do <<~RUBY
  # Public blog routes
  root 'posts#index'
  resources :posts, only: [:index, :show]

RUBY
end

say "#{INDENT}✅ Basic routes configured", :green
