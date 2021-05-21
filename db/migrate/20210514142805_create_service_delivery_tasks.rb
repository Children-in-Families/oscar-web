class CreateServiceDeliveryTasks < ActiveRecord::Migration
  def change
    create_table :service_delivery_tasks do |t|
      t.references :task, index: true, foreign_key: true
      t.references :service_delivery, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
