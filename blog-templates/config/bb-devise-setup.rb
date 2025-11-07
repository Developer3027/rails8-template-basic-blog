# Create a Admin user for Blog Management with Devise
# # Use apply from Thor to use in template.

# ==== Install Devise (Admin-Only) ====
say "#{INDENT}Installing Devise and creating Admin model...", :blue
generate 'devise:install'

# Generate Devise for an 'Admin' model, not 'User'
# This command generates the Devise model and its migration.
# We'll then modify the generated migration.
generate 'devise', 'Admin'

# Important: After `generate 'devise', 'Admin'`, Rails creates a migration like
# `db/migrate/YYYYMMDDHHMMSS_devise_create_admins.rb`.
# We need to inject additional columns into *that specific migration file*.

# Find the most recently created Devise Admin migration file
# This is a bit tricky, but generally the last migration file generated.
# A more robust way might be to look for "create_admins" in the filename.
devise_admin_migration_file = Dir.glob("db/migrate/*_devise_create_admins.rb").max_by { |f| File.basename(f).split('_').first.to_i }

if devise_admin_migration_file.nil?
  say "#{INDENT}#{RED}❌ Error: Could not find Devise Admin migration file. Please check `db/migrate` manually.#{RESET}", :red
  exit 1
end

say "#{INDENT}Adding blog meta columns to Devise Admin migration...", :blue
inject_into_file devise_admin_migration_file, after: "t.string :encrypted_password, null: false, default: \"\"\n\n" do <<~RUBY.split("\n").map { |line| "      #{line}" }.join("\n") + "\n"
    t.string :name
    t.string :title # e.g., "Lead Blogger", "Administrator"
    t.text :bio # Short bio for meta/about page
    t.string :profile_picture_url # Or use ActiveStorage for this later
    t.jsonb :social_media_links, default: [] # jsonb with default empty array
RUBY
end

gsub_file 'config/initializers/devise.rb',
      /^  # config\.scoped_views = false/,
      '  config.scoped_views = true'

say "#{INDENT}Modifying Devise Admin Model...", :green
