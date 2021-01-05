class AddRelationshipToCarer < ActiveRecord::Migration[5.2]
  def change
    add_column :carers, :suburb, :string, default: ''
    add_column :carers, :description_house_landmark, :string, default: ''
    add_column :carers, :directions, :string, default: ''

    add_column :carers, :street_line1, :string, default: ''
    add_column :carers, :street_line2, :string, default: ''

    add_column :carers, :plot, :string, default: ''
    add_column :carers, :road, :string, default: ''
    add_column :carers, :postal_code, :string, default: ''
    add_reference :carers, :state, index: true, foreign_key: true
    add_reference :carers, :township, index: true, foreign_key: true
    add_reference :carers, :subdistrict, index: true, foreign_key: true
  end
end
