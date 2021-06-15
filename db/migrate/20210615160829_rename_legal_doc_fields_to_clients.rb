class RenameLegalDocFieldsToClients < ActiveRecord::Migration
  def change
    rename_column :clients, :detail_form_of_judicial_police, :screening_interview_form
    change_column :clients, :screening_interview_form, :boolean, default: false, using: "screening_interview_form::boolean"
    add_column :clients, :screening_interview_form_option, :string
    add_column :clients, :screening_interview_form_files, :string, default: [], array: true
  end
end
