class AddCounterCacheToAllAssociations < ActiveRecord::Migration[5.2]
  def change
    add_column :agencies,         :agencies_clients_count,  :integer, default: 0

    add_column :provinces,        :cases_count,      :integer, default: 0
    add_column :provinces,        :clients_count,    :integer, default: 0
    add_column :provinces,        :families_count,   :integer, default: 0
    add_column :provinces,        :partners_count,   :integer, default: 0

    add_column :referral_sources, :clients_count,    :integer, default: 0
    add_column :users,            :clients_count,    :integer, default: 0

    add_column :users,            :cases_count,      :integer, default: 0
    add_column :families,         :cases_count,      :integer, default: 0
    add_column :partners,         :cases_count,      :integer, default: 0

    add_column :domains,          :tasks_count,      :integer, default: 0
    add_column :users,            :tasks_count,      :integer, default: 0

    add_column :provinces,        :users_count,      :integer, default: 0
    add_column :departments,      :users_count,      :integer, default: 0

    add_column :domain_groups,    :domains_count,    :integer, default: 0
  end
end
