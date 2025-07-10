![Rails](https://img.shields.io/badge/rails-8.0.0-orange?logo=rubyonrails)
![Ruby](https://img.shields.io/badge/ruby-3.3.0-red?logo=ruby)
![Devise](https://img.shields.io/badge/auth-devise-purple?logo=rubyonrails)
![Status](https://img.shields.io/badge/template-working-f46519?logo=rubyonrails)
![License](https://img.shields.io/badge/license-MIT-green)
![Powered By](https://img.shields.io/badge/powered%20by-coffee-brown)

# Rails 8 Template for Blog

This template is designed to build a blog from the "Rails new" command. You can read more about templates [here](https://guides.rubyonrails.org/rails_application_templates.html). You can use this template in a already existing app or to build a new. I would recommend using Rails 8.0.2 or up and Ruby 3.3.0 or up. You should also have FFmpeg and LibVips. Node 18 or up is handy, not required. To use the commands below just run them in the appropriate environment.

**Existing App**
```bash
bin/rails app:template LOCATION=https://raw.githubusercontent.com/Developer3027/rails8-template-basic-blog/refs/heads/main/main-template.rb
```

**New Application**
```bash
rails new my-app -d postgresql -c tailwind -m https://raw.githubusercontent.com/Developer3027/rails8-template-basic-blog/refs/heads/main/main-template.rb
```

Listed below are the features for this template:

## Version Checks

I built this template with the latest version of Rails, so it will check the version of Rails being used for install and exit if not Rails 8.0.2. I don't see why this would not run on version 8, need to modify the check. Doubt it will run on less as the template system is for 8. I check for at least Ruby version 3.3.0. I would not recommend using less. The blog uses Action Text and Active Storage. Active Storage will use FFmpeg and LibVips for video and image manipulation. These services are not set up in this template but the checks are made. It is not looking for versions, just install. If one is not found it will exit and provide a message on how to install. Node is not used specifically in this template but is handy for Rails apps, may even be required depending on your Tailwind needs. Will check for Node and version, looking for version 18, but will not exit if minor version found. Will warn if minor version found.

* **Version Check** This template requires and will check for:
  * **Rails 8** Version 8.0.2. Newest version as of Jul 2025.
  * **Ruby 3** Version 3.3.0 or higher.
  * **FFmpeg** Need FFmpeg installed, not checking version.
  * **LibVips** Need LibVips installed, not checking version.
  * **Node** Check for node and version 18 or higher. Ok if lower, show warning.

If a required check fails, it will exit. If checks pass it will ask if you want to continue. Some checks are a more of a suggestion so it will present the information it gathered and ask you what to do.

## Backend

### Configuration

* Install any gems needed by the app.
* Remove the database config and create the new one. I prefer a more general setup for PostgreSQL on localhost that uses the default pg username and password. This is the default standard for pg. Feel free to change it. Create the new database.
* Install Action Text and Active Storage.
* Modify the gitignore to include the bundle folder. This greatly reduces the git push to github. This can cause issues with github actions. If there is a issue, modify the workflow to call bundle after grabbing the code.

### Asset Pipeline

Images used in the initial build need to be available in the asset pipeline. The cover images for articles, profile avatar or other images need to be copied over. Do this early so any seed operations or generations will have access.

### Admin with Devise

Use devise to create the admin for the site. The template will set up devise and create the admin. Admin will include fields like name, handle, and avatar plus others. Once the model, controllers are created, modified, and routes modified, ask for admin information from the user. Use that information to seed the admin and create it. Use the avatar copied earlier to seed the active storage association.

### Modify Application Controller

Add the layouts checker to controller. If admin is logged in the root will be the dashboard. If not the root will be post index. The view/layouts folder contains the application.html.erb which is the layout for root of the app. Will create another called admin for the root of the app if a admin is logged in. The normal application root will have a typical header. The admin dashboard will have a sidebar.

_NOTE_ The admin can perform CRUD actions for the blog. The admin will manage the blog from a dashboard they log into. Anyone visiting the blog can view published articles. With this in mind, there may be a public controller and a admin controller for the same model.

### Post Model

Generate the post model. This model is for the articles. It includes title, subtitle, content, featured, and published_at. The featured flag is a boolean to show a featured article at the top of the blog. Published_at is used to create scopes for the admin so they can set articles to various status of draft, published or scheduled. Admin will need to be referenced. Each article is written by a admin. Each article has a image.

### Generate admin and public post controllers

Admin post controller is secured and includes CRUD actions. Public post controller include index and show actions presenting post variables for each. Modify routes for the public root to _post#index_

### Seeding

Various articles need to be seeded. One feature and two more general articles. This will provide a solid blog page when initially viewing the site. Include cover images copied earlier. Meta data from admin used.

## Frontend

There are two set of views. One for the admin and one for the public. The public root post page will have the header at the top, a featured article card and a article card. The dashboard will have a sidebar navigation. Devise views will be used.
