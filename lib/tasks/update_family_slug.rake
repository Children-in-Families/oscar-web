namespace 'family_slug' do
  desc 'update family slug'
  task update: :environment do
    Organization.without_shared.each do |org|
      Organization.switch_to org.short_name

      Family.find_each do |family|
        unless family.slug.present?
          slug = "#{org.short_name}-#{family.id}"
          family.update_columns(slug: slug)
        end
      end
      puts "finish updating slug in #{org.short_name}"
    end
  end
end
  