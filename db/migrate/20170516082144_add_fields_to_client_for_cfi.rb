class AddFieldsToClientForCfi < ActiveRecord::Migration[5.2]
  def change
    add_column :clients, :live_with,           :string,  default: ''
    add_column :clients, :poverty_certificate, :integer, default: 0
    add_column :clients, :rice_support,        :integer, default: 0
  end
end
