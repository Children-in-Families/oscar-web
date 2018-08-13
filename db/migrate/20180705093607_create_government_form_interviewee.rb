class CreateGovernmentFormInterviewee < ActiveRecord::Migration
  def change
    create_table :government_form_interviewees do |t|
      t.references :government_form, index: true, foreign_key: true
      t.references :interviewee, index: true, foreign_key: true

      t.timestamps
    end
  end
end
