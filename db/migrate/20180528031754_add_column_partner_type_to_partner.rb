class AddColumnPartnerTypeToPartner < ActiveRecord::Migration
  def change
    add_column :partners, :partner_type, :string, array: true, default: []
  end
end
