admin = User.new
admin.first_name = 'Admin'
admin.email = ENV['ADMIN_USERNAME']
admin.password = ENV['ADMIN_PASSWORD']
admin.roles = 'admin'

admin.save(validate: false)
