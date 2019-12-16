namespace :referral_sources do
  desc "Restructure referral sources/ referral source category"
  task restructure: :environment do
    REFERRAL_SOURCES = ['ក្រសួង សអយ/មន្ទីរ សអយ', 'អង្គការមិនមែនរដ្ឋាភិបាល', 'មន្ទីរពេទ្យ', 'នគរបាល', 'តុលាការ/ប្រព័ន្ធយុត្តិធម៌', 'រកឃើញនៅតាមទីសាធារណៈ', 'ស្ថាប័នរដ្ឋ', 'មណ្ឌលថែទាំបណ្ដោះអាសន្ន', 'ទូរស័ព្ទទាន់ហេតុការណ៍', 'មកដោយខ្លួនឯង', 'គ្រួសារ', 'មិត្តភក្ដិ', 'អាជ្ញាធរដែនដី', 'ផ្សេងៗ', 'សហគមន៍', 'ព្រះវិហារ'].freeze
    Organization.all.each do |org|
      Organization.switch_to org.short_name
      Client.skip_callback(:save, :after, :create_client_history)
      Client.joins(:referral_source).each do |client|
        if REFERRAL_SOURCES.include?(client.referral_source.try(:name))
          client.referral_source_category_id = client.referral_source.id
          client.referral_source = nil
          client.save(validate: false)
        end
      end
    end
  end
end
