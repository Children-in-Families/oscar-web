class AddClientsFieldToFamily < ActiveRecord::Migration
  def up
    add_column :families, :children, :integer, array: true, default: []
    # Ignore scope, because this migration added before deleted_at field added
    Family.with_deleted.each do |family|
      family.update(children: family.client_ids.uniq) if family.client_ids.any?
    end
  end

  def down
    remove_column :families, :children
  end
end
