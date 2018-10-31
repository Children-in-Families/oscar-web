class AddCustomDomainToDomain < ActiveRecord::Migration
  def change
    add_column :domains, :custom_domain, :boolean, default: false
  end
end
