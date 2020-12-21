class CreateIntervention < ActiveRecord::Migration[5.2]
  def change
    create_table :interventions do |t|
      t.string :action, default: ''
      t.timestamps
    end
  end
end
