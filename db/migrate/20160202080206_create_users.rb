class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :first_name, default: ''
      t.string :last_name, default: ''
      t.string :roles, default: 'case worker'
      t.date   :start_date
      t.string :job_title, default: ''
      t.string :mobile, default: ''
      t.date   :date_of_birth
      t.boolean :archived, default: false

      t.references :province
      t.references :department

      t.timestamps
    end
  end
end
