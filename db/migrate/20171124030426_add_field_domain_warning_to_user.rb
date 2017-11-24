class AddFieldDomainWarningToUser < ActiveRecord::Migration
  def change
    add_column :users, :domain_warning, :boolean, default: false
  end
end
