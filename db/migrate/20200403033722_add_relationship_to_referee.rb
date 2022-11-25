class AddRelationshipToReferee < ActiveRecord::Migration[5.2]
  def change
    add_column :referees, :suburb, :string, default: ''
    add_column :referees, :description_house_landmark, :string, default: ''
    add_column :referees, :directions, :string, default: ''

    add_column :referees, :street_line1, :string, default: ''
    add_column :referees, :street_line2, :string, default: ''

    add_column :referees, :plot, :string, default: ''
    add_column :referees, :road, :string, default: ''
    add_column :referees, :postal_code, :string, default: ''

    add_reference :referees, :state, index: true, foreign_key: true
    add_reference :referees, :township, index: true, foreign_key: true
    add_reference :referees, :subdistrict, index: true, foreign_key: true
  end
end
