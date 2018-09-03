class AddGeographyReferenceToGovernmentForm < ActiveRecord::Migration
  def change
    add_reference :government_forms, :province, index: true, foreign_key: true
    add_reference :government_forms, :district, index: true, foreign_key: true
    add_reference :government_forms, :commune, index: true, foreign_key: true
    add_reference :government_forms, :village, index: true, foreign_key: true
  end
end
