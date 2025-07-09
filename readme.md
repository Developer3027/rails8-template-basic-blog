# Rails 8 Template for Blog

This template is designed to build a blog from the "Rails new" command. Listed below are the features for this template:

## Version Checks

I built this template with the latest version of Rails, so it will check the version of Rails being used for install and exit if not Rails 8.0.2. I don't see why this would not run on version 8, need to modify the check. Doubt it will run on less as the template system is for 8. I check for at least Ruby version 3.3.0. I would not recommend using less. The blog uses Action Text and Active Storage. Active Storage will use FFmpeg and LibVips for video and image manipulation. These services are not set up in this template but the checks are made. It is not looking for versions, just install. If one is not found it will exit and provide a message on how to install. Node is not used specifically in this template but is handy for Rails apps, may even be required depending on your Tailwind needs. Will check for Node and version, looking for version 18, but will not exit if minor version found. Will warn if minor version found.

* **Version Check** This template requires and will check for:
  * **Rails 8** Version 8.0.2. Newest version as of Jul 2025.
  * **Ruby 3** Version 3.3.0 or higher.
  * **FFmpeg** Need FFmpeg installed, not checking version.
  * **LibVips** Need LibVips installed, not checking version.
  * **Node** Check for node and version 18 or higher. Ok if lower, show warning.

