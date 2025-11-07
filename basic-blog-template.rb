# --- Configuration ---
# Define the desired indentation (e.g., 2 spaces)
INDENT = "  " # Two spaces - standard Ruby style

# ===== System Checks ====
# Run system checks
say "#{INDENT}Running system checks...", :blue
apply File.join(File.dirname(__FILE__), 'blog-templates', 'sys-checks.rb')

# CONFIRMATION
unless yes?("All checks passed.Continue with setup? (Y/n)", :cyan)
  say "Aborting template setup.", :red
  exit 0
end

say "Adding gems to Gemfile...", :blue
gem_group :development, :test do
  gem 'rspec-rails'
  gem 'factory_bot_rails'
end

gem_group :development do
  gem 'annotate'
end

gem 'devise'
gem 'actiontext'
gem 'image_processing', "~> 1.2"
gem 'active_model_serializers', '~> 0.10.0'
gem 'aws-sdk-s3'
gem 'friendly_id'
gem 'meta-tags'
gem "ransack"
gem 'pagy'

# After bundle, set up blog app.
after_bundle do
  # ==== Setup PostgreSQL ====
  say "#{INDENT}Configure PostgreSQL...", :blue
  remove_file 'config/database.yml'
  apply File.join(File.dirname(__FILE__), 'blog-templates', 'config', 'bb-pg-config.rb')

  # ==== Create database ====
  say "#{INDENT}Creating database...", :blue
  rails_command 'db:create'

  # ==== Active Storage + Action Text ====
  say "#{INDENT}Installing Active Storage and Action Text...", :blue
  rails_command 'active_storage:install'
  rails_command 'action_text:install'

  # ==== Set Storage.yml ====
  say "#{INDENT}Configure Storage.yml...", :blue
  remove_file 'config/storage.yml'
  apply File.join(File.dirname(__FILE__), 'blog-templates', 'config', 'bb-storage-config.rb')

  # ==== Modify production environment ====
  say "#{INDENT}Setting Active Storage service to :amazon in production.rb...", :blue
  gsub_file 'config/environments/production.rb',
      /^  config\.active_storage\.service = :local/,
      '  config.active_storage.service = :amazon'

  # ==== Git ignore ====
  say "#{INDENT}Updating .gitignore...", :blue
  remove_file '.gitignore'
  apply File.join(File.dirname(__FILE__), 'blog-templates', 'bb-gitignore.rb')


  # ======================================================
  # ==== Copy Images ====
  say "#{INDENT}Adding images to pipeline...", :blue
  copy_file File.join(File.dirname(__FILE__), 'blog-templates', 'images', 'logo.svg'), "app/assets/images/logo.svg"
  copy_file File.join(File.dirname(__FILE__), 'blog-templates', 'images', 'profile.png'), "app/assets/images/profile.png"
  copy_file File.join(File.dirname(__FILE__), 'blog-templates', 'images', 'railamellon.jpg'), "app/assets/images/railamellon.jpg"
  copy_file File.join(File.dirname(__FILE__), 'blog-templates', 'images', 'meta-railamellon.jpg'), "app/assets/images/meta-railamellon.jpg"
  copy_file File.join(File.dirname(__FILE__), 'blog-templates', 'images', 'red-rails.jpg'), "app/assets/images/red-rails.jpg"
  copy_file File.join(File.dirname(__FILE__), 'blog-templates', 'images', 'ruby-coffee.jpg'), "app/assets/images/ruby-coffee.jpg"
  copy_file File.join(File.dirname(__FILE__), 'blog-templates', 'images', '_signout.html.erb'), "app/views/admin/sidebar/icons/_signout.html.erb"
  copy_file File.join(File.dirname(__FILE__), 'blog-templates', 'images', '_menu.html.erb'), "app/views/admin/sidebar/icons/_menu.html.erb"
  copy_file File.join(File.dirname(__FILE__), 'blog-templates', 'images', '_home.html.erb'), "app/views/admin/sidebar/icons/_home.html.erb"
  copy_file File.join(File.dirname(__FILE__), 'blog-templates', 'images', '_file_pen.html.erb'), "app/views/admin/sidebar/icons/_file_pen.html.erb"

  # ======================================================
  # ==== Install Devise (Admin-Only) ====
  # ==== Apply Devise setup from file ====
  apply File.join(File.dirname(__FILE__), 'blog-templates', 'config', 'bb-devise-setup.rb')

  # ==== Update Admin Model ====
  inject_into_file 'app/models/admin.rb', before: "end" do <<~RUBY.split("\n").map { |line| "  #{line}" }.join("\n") + "\n"
    has_many :posts
    has_one_attached :avatar
  RUBY
  end

  # ==== Devise admin Controller and Routes ====
  apply File.join(File.dirname(__FILE__), 'blog-templates', 'controllers', 'bb-admin-controller.rb')

    # ==== Generate Devise views ====
  say "#{INDENT}Generating Devise views...", :blue
  generate 'devise:views', 'admins'

  sleep 0.3

  # ==== Update Devise views ====
  say "#{INDENT}Updating Devise views...", :blue
  apply File.join(File.dirname(__FILE__), 'blog-templates', 'views', 'bb-devise-views.rb')

  # ======================================================

  # ==== Configure Active Model Serializers ====
  say "#{INDENT}Configuring Active Model Serializers...", :blue
  create_file 'config/initializers/active_model_serializers.rb', <<~RUBY
  ActiveModelSerializers.config.serialization_scope = nil
  ActiveModelSerializers.config.adapter = :json
  RUBY

  # ==== Generate Post Serializer ====
  say "#{INDENT}Creating PostSerializer for JSON API...", :blue
  empty_directory 'app/serializers'
  apply File.join(File.dirname(__FILE__), 'blog-templates', 'config', 'bb-post-serializer.rb')

  # ======================================================

  # ==== Generate Models ====
  # ==== Generate Category Model ====
  say "#{INDENT}Generating models...", :blue
  generate :model, "Category category_name:string category_description:text"

  # ==== Generate Post Model ====
  generate :model, "Post title:string subtitle:string published_at:datetime admin:references image_url:string meta_image_url:string slug:string keywords:jsonb meta_description:text featured:boolean"
  post_migration_file = Dir.glob("db/migrate/*_create_posts.rb").max_by { |f| File.basename(f).split('_').first.to_i }
  if post_migration_file
    say "#{INDENT}Adding default empty array to Post keywords column...", :blue
    inject_into_file post_migration_file, after: "t.jsonb :keywords" do <<~RUBY
    , default: []
    RUBY
    end
    say "#{INDENT}Adding default and unique partial index to Post featured column...", :blue
    inject_into_file post_migration_file, after: "t.boolean :featured" do <<~RUBY
    , default: false, null: false
    RUBY
    end
    say "#{INDENT}Adding unique partial index for 'featured' to Post migration...", :blue
    inject_into_file post_migration_file, after: "    end" do <<~RUBY

        add_index :posts, :featured, unique: true, where: "featured IS TRUE"
    RUBY
    end
  end

  # ==== Generate PostCategory Model ====
  generate :model, "PostCategory post:references category:references"

  # ==== Update Category Model ====
  apply File.join(File.dirname(__FILE__), 'blog-templates', 'models', 'bb-category-model.rb')

  # ==== Update Post Model ====
  apply File.join(File.dirname(__FILE__), 'blog-templates', 'models', 'bb-post-model.rb')

  # ==== Generate Public Post Controller ====
  say "#{INDENT}Generating public Posts controller (index, show)...", :blue
  generate :controller, 'Posts'
  apply File.join(File.dirname(__FILE__), 'blog-templates', 'controllers', 'bb-public-post-controller.rb')

  # ==== Generate Admin Post Controller ====
  say "#{INDENT}Generating admin Posts controller (secure actions)...", :blue
  generate :controller, 'Admin::Posts'
  apply File.join(File.dirname(__FILE__), 'blog-templates', 'controllers', 'bb-admin-post-controller.rb')

  # ==== Application Controller layout append ====
  say "#{INDENT}Appending Layout checker for admin...", :blue
  apply File.join(File.dirname(__FILE__), 'blog-templates', 'controllers', 'bb-app-controller.rb')

  # ==== Generate Public Root View ====
  say "#{INDENT}Copying public views...", :blue
  remove_file 'app/views/layouts/application.html.erb'
  copy_file File.join(File.dirname(__FILE__), 'blog-templates', 'views', 'layouts', 'application.html.erb'), "app/views/layouts/application.html.erb"

  # ==== Copying Header partial ====
  copy_file File.join(File.dirname(__FILE__), 'blog-templates', 'views', '_header.html.erb'), "app/views/layouts/_header.html.erb"

  copy_file File.join(File.dirname(__FILE__), 'blog-templates', 'views', 'layouts', 'admin.html.erb'), "app/views/layouts/admin.html.erb"

  copy_file File.join(File.dirname(__FILE__), 'blog-templates', 'views', 'post', 'index.html.erb'), "app/views/posts/index.html.erb"

  # ==== Copying Public Show View ====
  copy_file File.join(File.dirname(__FILE__), 'blog-templates', 'views', 'post', 'show.html.erb'), "app/views/posts/show.html.erb"
  # ==== Copying Featured Post partial ====
  copy_file File.join(File.dirname(__FILE__), 'blog-templates', 'views', 'post', 'partials', '_feature_card.html.erb'), "app/views/posts/partials/_feature_card.html.erb"
  # ==== Copying Post partial ====
  copy_file File.join(File.dirname(__FILE__), 'blog-templates', 'views', 'post', 'partials', '_no_featured_card.html.erb'), "app/views/posts/partials/_no_featured_card.html.erb"
    # ==== Copying No Featured partial ====
  copy_file File.join(File.dirname(__FILE__), 'blog-templates', 'views', 'post', 'partials', '_post_card.html.erb'), "app/views/posts/partials/_post_card.html.erb"

  copy_file File.join(File.dirname(__FILE__), 'blog-templates', 'views', 'admin', 'dashboard.html.erb'), "app/views/admin/dashboard.html.erb"

  copy_file File.join(File.dirname(__FILE__), 'blog-templates', 'views', 'admin', 'sidebar', '_index.html.erb'), "app/views/admin/sidebar/_index.html.erb"

  copy_file File.join(File.dirname(__FILE__), 'blog-templates', 'views', 'admin', 'sidebar', '_link.html.erb'), "app/views/admin/sidebar/_link.html.erb"
  copy_file File.join(File.dirname(__FILE__), 'blog-templates', 'views', 'admin', 'sidebar', '_signout.html.erb'), "app/views/admin/sidebar/_signout.html.erb"


  say "#{INDENT}Running final migrations...", :blue
  rails_command 'db:migrate'



  # ==== Seed Database ====
  say "#{INDENT}Amend the seeds.rb...", :blue
  apply File.join(File.dirname(__FILE__), 'blog-templates', 'config', 'bb-seed.rb')

  say "#{INDENT}Seeding database...", :blue
  rails_command 'db:seed'

  generate 'rspec:install'


  # ==== Git Init ====
  git :init
  git add: '.'
  git commit: "-m 'Initial commit: Rails blog template with Devise, Tailwind, PostgreSQL'"


  # Final messages
  say "\n✅ Successfully created Rails blog template!", :green
  say "\nNext steps:"
  say "  1. Tailor your routes in config/routes.rb"
  say "  3. Deploy to Heroku: `heroku create && git push heroku main && heroku run rails db:migrate db:seed`"
  say "\n⚠️  Heroku Configuration Required:", :yellow
  say "  1. Set AWS credentials:"
  say "     heroku config:set AWS_ACCESS_KEY_ID=xxx AWS_SECRET_ACCESS_KEY=xxx"
  say "  2. Set bucket/region:"
  say "     heroku config:set S3_BUCKET_NAME=your-bucket AWS_REGION=us-east-2"
end
