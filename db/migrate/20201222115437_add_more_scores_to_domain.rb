class AddMoreScoresToDomain < ActiveRecord::Migration
  def change
    add_column :domains, :score_5_color, :string, default: ''
    add_column :domains, :score_6_color, :string, default: ''
    add_column :domains, :score_7_color, :string, default: ''
    add_column :domains, :score_8_color, :string, default: ''
    add_column :domains, :score_9_color, :string, default: ''
    add_column :domains, :score_10_color, :string, default: ''

    add_column :domains, :score_5_definition, :text, default: ''
    add_column :domains, :score_6_definition, :text, default: ''
    add_column :domains, :score_7_definition, :text, default: ''
    add_column :domains, :score_8_definition, :text, default: ''
    add_column :domains, :score_9_definition, :text, default: ''
    add_column :domains, :score_10_definition, :text, default: ''

    add_column :domains, :score_5_local_definition, :text, default: ''
    add_column :domains, :score_6_local_definition, :text, default: ''
    add_column :domains, :score_7_local_definition, :text, default: ''
    add_column :domains, :score_8_local_definition, :text, default: ''
    add_column :domains, :score_9_local_definition, :text, default: ''
    add_column :domains, :score_10_local_definition, :text, default: ''
  end
end
