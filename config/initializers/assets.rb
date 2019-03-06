# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.

# Rich text editor for the Domain
Rails.application.config.assets.precompile += %w(jquery.nicescroll.js animate.css toastr.min.css custom.css green.png)
Rails.application.config.assets.precompile += %w(chariot.min.js chariot.min.css)
