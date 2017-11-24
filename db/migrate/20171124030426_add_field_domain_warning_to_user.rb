class AddFieldDomainWarningToUser < ActiveRecord::Migration
  def up
    add_column :users, :domain_warning, :boolean, default: false
  end

  def down
    remove_column :users, :domain_warning, :boolean, default: false
  end
end
