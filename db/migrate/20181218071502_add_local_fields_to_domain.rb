class AddLocalFieldsToDomain < ActiveRecord::Migration
  def change
    add_column :domains, :local_description, :text, default: ''
    add_column :domains, :score_1_local_definition, :text, default: ''
    add_column :domains, :score_2_local_definition, :text, default: ''
    add_column :domains, :score_3_local_definition, :text, default: ''
    add_column :domains, :score_4_local_definition, :text, default: ''
  end
end
