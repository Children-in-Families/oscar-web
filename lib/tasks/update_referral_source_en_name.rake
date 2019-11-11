namespace :referral_source_en_name do
  desc 'Update referrral source data to both en and km'
  task update: :environment do

    Organization.where.not(short_name: 'shared').each do |org|
      Organization.switch_to org.short_name
      current_org = Organization.current
      referral_sources = ['ក្រសួង សអយ/មន្ទីរ សអយ--Government Ministry Referral', 'អង្គការមិនមែនរដ្ឋាភិបាល--Non-Government Organization', 'មន្ទីរពេទ្យ--Hospital', 'នគរបាល--Police', 'តុលាការ/ប្រព័ន្ធយុត្តិធម៌--Court/Justice System', 'រកឃើញនៅតាមទីសាធារណៈ--Found in Public', 'ស្ថាប័នរដ្ឋ--State Institutions', 'មណ្ឌលថែទាំបណ្ដោះអាសន្ន--Temporary Care Institution', 'ទូរស័ព្ទទាន់ហេតុការណ៍--Emergency Hotline', 'មកដោយខ្លួនឯង--Self-referral', 'គ្រួសារ--Family', 'មិត្តភក្ដិ--Friend', 'អាជ្ញាធរដែនដី--Local Authorities', 'ផ្សេងៗ--Other', 'សហគមន៍--Community', 'ព្រះវិហារ--Church']
      referral_sources.each do |referral_source|
        km_referral = referral_source.split('--').first.squish
        en_referral = referral_source.include?('--') ? referral_source.split('--').last.squish : ''
        referral = ReferralSource.find_by(name: km_referral)
        next if referral.nil?
        referral.update_column('name', km_referral)
        referral.update_column('name_en', en_referral)
      end

    end
  end
end
