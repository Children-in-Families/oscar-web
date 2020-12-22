class CreateClientInterviewee < ActiveRecord::Migration[5.2]
  def change
    create_table :client_interviewees do |t|
      t.references :client, index: true, foreign_key: true
      t.references :interviewee, index: true, foreign_key: true
      t.timestamps
    end
  end
end
