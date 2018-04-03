class CreateAdvancedSearches < ActiveRecord::Migration
  def change
    create_table :advanced_searches do |t|
      t.string :name
      t.text :description
      t.jsonb :queries
      t.jsonb :field_visible
      t.string :custom_forms
      t.string :program_streams
      t.string :enrollment_check, default: ''
      t.string :tracking_check, default: ''
      t.string :exit_form_check, default: ''
      t.string :quantitative_check, default: ''
      t.timestamps null: false
    end
  end
end
