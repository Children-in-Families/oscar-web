class AddFieldHotlineCheckToAdvancedSearch < ActiveRecord::Migration
  def change
    add_column :advanced_searches, :hotline_check, :string, default: ''
  end
end
