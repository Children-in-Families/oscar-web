class CreateIntervention < ActiveRecord::Migration
  def change
    create_table :interventions do |t|
      t.string :action, default: ''
      t.timestamps
    end
  end
end
