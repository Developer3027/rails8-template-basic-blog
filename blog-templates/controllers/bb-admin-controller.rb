# Create custom Devise controllers for Admin strong params
# Use apply from Thor to use in template.

say "#{INDENT}Creating custom Devise controllers for Admin...", :blue

# Generate the Devise controllers so we can customize them
generate 'devise:controllers', 'admins', '-c=registrations sessions'


# Create the admin view controller
create_file 'app/controllers/admin_controller.rb', <<~RUBY
  class AdminController < ApplicationController
    before_action :authenticate_admin!

    def dashboard
      @admin = current_admin
    end

    private

  end
RUBY

# Update the registrations controller to permit our custom fields
say "#{INDENT}Configuring strong params for Admin fields...", :blue

create_file 'app/controllers/admins/registrations_controller.rb', <<~RUBY
# frozen_string_literal: true

class Admins::RegistrationsController < Devise::RegistrationsController
  before_action :authenticate_admin!, except: [ :show ]
  before_action :configure_sign_up_params, only: [ :create ]
  before_action :configure_account_update_params, only: [ :update ]

  # GET /resource/sign_up
  def new
    # Only allow existing admins to create new admin accounts
    redirect_to root_path unless admin_signed_in?
    super
  end

  # POST /resource
  def create
    # Only allow existing admins to create new admin accounts
    redirect_to root_path unless admin_signed_in?
    super
  end

  private
  def after_sign_up_path_for(resource)
    admin_root_path
  end

  def after_inactive_sign_up_path_for(resource)
    admin_root_path
  end

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [
      :name, :title, :handle, :bio, :avatar, social_media_links: []
    ])
  end

  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [
      :name, :title, :handle, :bio, :avatar, social_media_links: []
    ])
  end
end
RUBY

# Update routes to use the custom controllers
say "#{INDENT}Updating routes to use custom Devise controllers...", :blue

# First, let's remove any existing devise_for :admins lines
gsub_file 'config/routes.rb', /^\s*devise_for :admins.*$/, ''

# Remove any empty lines that might be left behind
gsub_file 'config/routes.rb', /\n\s*\n\s*\n/, "\n\n"

# Replace the existing devise_for line with one that uses our custom controllers
inject_into_file 'config/routes.rb', after: "Rails.application.routes.draw do\n" do <<-RUBY
  # In config/routes.rb (your bb-routes.rb file, or this block directly in main template)
  devise_for :admins, controllers: {
      registrations: 'admins/registrations',
      sessions: 'admins/sessions'
    }, skip: [:passwords, :confirmations, :registrations] # Keep passwords skip if no 'forgot password' flow

  authenticated :admin do
    root to: 'admin#dashboard', as: :admin_root

    devise_scope :admin do
      # Route for creating a new admin (only by existing admin)
      get 'admins/sign_up', to: 'admins/registrations#new', as: :new_admin_registration
      post 'admins', to: 'admins/registrations#create', as: :admin_registration_creation

      # Routes for current admin to edit their own profile/password
      # Change 'as: :admin_registration_profile' to 'as: :admin_registration'
      resource :admin_registration, only: [:edit, :update], controller: 'devise/registrations', as: :admin_registration # <-- CORRECTED AS NAME
    end
  end
  # Root route for public
  root 'posts#index'
RUBY
end

# Also create a basic sessions controller for consistency
create_file 'app/controllers/admins/sessions_controller.rb', <<~RUBY
# frozen_string_literal: true

class Admins::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  # def create
  #   super
  # end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end

  # The path used after signing in.
  def after_sign_in_path_for(resource)
    admin_root_path
  end

  # The path used after signing out.
  def after_sign_out_path_for(resource_or_scope)
    root_path
  end
end
RUBY

say "#{INDENT}✅ Custom Devise controllers created with strong params support", :green
