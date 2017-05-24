class AddFieldFcfNgoToOrganization < ActiveRecord::Migration
  def change
    add_column :organizations, :fcf_ngo, :boolean, default: false
  end
end
