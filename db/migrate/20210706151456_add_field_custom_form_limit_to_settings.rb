class AddFieldCustomFormLimitToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :custom_field_limit, :integer, default: 0
    add_column :settings, :custom_field_frequency, :string, default: "week"
  end
end
