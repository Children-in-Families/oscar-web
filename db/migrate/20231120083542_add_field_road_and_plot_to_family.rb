class AddFieldRoadAndPlotToFamily < ActiveRecord::Migration
  def change
    add_column :families, :road, :string unless column_exists? :families, :road
    add_column :families, :plot, :string unless column_exists? :families, :plot
    add_column :families, :postal_code, :string unless column_exists? :families, :postal_code
  end
end
