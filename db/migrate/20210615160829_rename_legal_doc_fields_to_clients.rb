class RenameLegalDocFieldsToClients < ActiveRecord::Migration
  def change
    remove_column :clients, :detail_form_of_judicial_police, :string
    add_column :clients, :screening_interview_form, :boolean, default: false
    add_column :clients, :screening_interview_form_option, :string
    add_column :clients, :screening_interview_form_files, :string, default: [], array: true
  end
end
