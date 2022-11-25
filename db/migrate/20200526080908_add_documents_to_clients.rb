class AddDocumentsToClients < ActiveRecord::Migration[5.2]
  def change
    add_column :clients, :national_id, :boolean, default: false, null: false
    add_column :clients, :birth_cert, :boolean, default: false, null: false
    add_column :clients, :family_book, :boolean, default: false, null: false
    add_column :clients, :passport, :boolean, default: false, null: false
    add_column :clients, :travel_doc, :boolean, default: false, null: false
    add_column :clients, :referral_doc, :boolean, default: false, null: false
    add_column :clients, :local_consent, :boolean, default: false, null: false
    add_column :clients, :police_interview, :boolean, default: false, null: false
    add_column :clients, :other_legal_doc, :boolean, default: false, null: false

    add_column :clients, :national_id_files, :string, default: [], array: true
    add_column :clients, :birth_cert_files, :string, default: [], array: true
    add_column :clients, :family_book_files, :string, default: [], array: true
    add_column :clients, :passport_files, :string, default: [], array: true
    add_column :clients, :travel_doc_files, :string, default: [], array: true
    add_column :clients, :referral_doc_files, :string, default: [], array: true
    add_column :clients, :local_consent_files, :string, default: [], array: true
    add_column :clients, :police_interview_files, :string, default: [], array: true
    add_column :clients, :other_legal_doc_files, :string, default: [], array: true
  end
end
