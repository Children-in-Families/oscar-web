class AddDefinitionToDomain < ActiveRecord::Migration[5.2]
  def change
    add_column :domains, :score_1_definition, :text, default: ''
    add_column :domains, :score_2_definition, :text, default: ''
    add_column :domains, :score_3_definition, :text, default: ''
    add_column :domains, :score_4_definition, :text, default: ''
  end
end
