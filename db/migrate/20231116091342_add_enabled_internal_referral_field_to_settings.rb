class AddEnabledInternalReferralFieldToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :enabled_internal_referral, :boolean, default: false
    Rails.cache.delete([Apartment::Tenant.current, 'current_setting'])
    Rails.cache.delete([Apartment::Tenant.current, 'table_name', 'settings'])
    Rails.cache.delete(['current_organization', Apartment::Tenant.current, Organization.only_deleted.count])
  end
end
