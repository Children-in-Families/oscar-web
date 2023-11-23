class AddFieldRoadAndPlotToFamily < ActiveRecord::Migration
  def change
    add_column :families, :road, :string
    add_column :families, :plot, :string
    add_column :families, :postal_code, :string
  end
end
