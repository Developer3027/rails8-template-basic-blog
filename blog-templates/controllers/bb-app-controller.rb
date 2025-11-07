inject_into_file 'app/controllers/application_controller.rb', before: 'end' do <<-RUBY
  layout :layout_by_resource

  private
  # Choose the layout based on whether the user is signed in or not.
  #
  # If the user is signed in, it will use the milk_admin layout.
  # Otherwise, it will use the application layout.
  def layout_by_resource
    if admin_signed_in?
      "admin"
    else
      "application"
    end
  end
RUBY
end
