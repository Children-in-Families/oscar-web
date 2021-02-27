class AddFieldTypeToDomains < ActiveRecord::Migration
  def change
    add_column :domains, :domain_type, :string
    add_index :domains, :domain_type

    reversible do |dir|
      dir.up do
        Domain.update_all(domain_type: 'client')
      end
    end
  end
end
