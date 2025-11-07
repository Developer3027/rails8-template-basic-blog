# blog-templates/views/bb-devise-views.rb

# 1. Clean up _links.html.erb
# We want ONLY 'Log in' link. Remove all others for skipped features.
# This approach is more robust: replace the entire file content.
create_file 'app/views/admins/shared/_links.html.erb', <<~ERB, force: true # Use force: true to overwrite
  <\% if controller_name != 'sessions' %>
    <\%= link_to "Log in", new_session_path(resource_name) %><br />
  <\% end %>
ERB

# 2. Create _admin_fields.html.erb (for name, bio, avatar, social_media_links)
# Ensure ERB is escaped here.
create_file 'app/views/admins/shared/_admin_fields.html.erb', <<~ERB
  <div class="field">
    <\%= f.label :name %><br />
    <\%= f.text_field :name, class: "w-full p-2 border rounded" %>
  </div>

  <div class="field">
    <\%= f.label :title %><br />
    <\%= f.text_field :title, class: "w-full p-2 border rounded" %>
  </div>

  <div class="field">
    <\%= f.label :bio %><br />
    <\%= f.text_area :bio, class: "w-full p-2 border rounded" %>
  </div>

  <div class="field">
    <\%= f.label :handle %><br />
    <\%= f.text_field :handle, class: "w-full p-2 border rounded" %>
  </div>

  <div class="field">
    <\%= f.label :avatar %> (Profile Picture)<br />
    <\%= f.file_field :avatar, class: "w-full p-2 border rounded" %>
    <\% if f.object.avatar.attached? %> <\# Use f.object.avatar instead of resource.avatar here>
      <div class="mt-2">
        Current: <img src="<\%= url_for(f.object.avatar.variant(resize_to_limit: [64, 64])) %>" class="w-16 h-16 rounded-full object-cover">
        <\%= f.check_box :remove_avatar %> <\#%= f.label :remove_avatar, "Remove avatar" %>
      </div>
    <\% end %>
  </div>

  <\%# Social Media Links - Assuming a single text field where comma-separated values are handled by controller %>
  <div class="field">
    <\%= f.label :social_media_links, "Social Media Links (comma-separated URLs)" %><br />
    <\%= f.text_field :social_media_links, value: (f.object.social_media_links&.join(',') if f.object.social_media_links.is_a?(Array)), class: "w-full p-2 border rounded" %> <\# Value for JSONB array
  </div>
ERB

# 3. Inject _admin_fields into registrations/edit.html.erb
# The target `after:` is sensitive. Let's find a reliable common line.
# A good target is usually after the error messages partial.
say "#{INDENT}Injecting admin fields into registrations edit view...", :blue
inject_into_file 'app/views/admins/registrations/edit.html.erb', after: '<%= render "admins/shared/error_messages", resource: resource %>' do <<~ERB

  <div class="my-4 p-4 border rounded bg-slate-50">
    <\%= render "admins/shared/admin_fields", f: f %>
  </div>
ERB
end

# 4. Modify registrations/new.html.erb (for new admin creation by existing admin)
say "#{INDENT}Injecting admin fields into registrations new view...", :blue
inject_into_file 'app/views/admins/registrations/new.html.erb', after: '<%= render "admins/shared/error_messages", resource: resource %>' do <<~ERB

  <div class="my-4 p-4 border rounded bg-slate-50">
    <\%= render "admins/shared/admin_fields", f: f %>
  </div>
ERB
end

# 5. Clean up other Devise views if they contain unwanted links (e.g., mailer templates)
# This is less critical but can prevent future issues if mailers are enabled.
# For simplicity, if mailers aren't critical now, we can skip specific cleaning.
