class AddFrequencyToCustomField < ActiveRecord::Migration[5.2]
  def change
    add_column :custom_fields, :frequency, :string, default: ''
    add_column :custom_fields, :time_of_frequency, :integer, default: 0
  end
end
