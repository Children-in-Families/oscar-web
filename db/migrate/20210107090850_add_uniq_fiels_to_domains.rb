class AddUniqFielsToDomains < ActiveRecord::Migration
  def change
    add_index :domains, %i[name identity custom_assessment_setting_id domain_type], unique: true, name: 'index_domains_on_name_identity_custom_setting_domain_type'
  end
end
