class AddClientsFieldToFamily < ActiveRecord::Migration
  def up
    add_column :families, :children, :integer, array: true, default: []

    Family.all.each do |family|
      family.update(children: family.client_ids.uniq) if family.client_ids.any?
    end
  end

  def down
    remove_column :families, :children
  end
end
