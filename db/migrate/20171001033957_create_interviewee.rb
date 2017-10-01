class CreateInterviewee < ActiveRecord::Migration
  def change
    create_table :interviewees do |t|
      t.string :name, default: ''
      t.timestamps
    end
  end
end
