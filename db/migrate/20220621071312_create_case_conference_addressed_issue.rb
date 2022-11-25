class CreateCaseConferenceAddressedIssue < ActiveRecord::Migration[5.2]
  def change
    create_table :case_conference_addressed_issues do |t|
      t.integer :case_conference_domain_id
      t.string :title
    end
    add_index :case_conference_addressed_issues, :case_conference_domain_id, name: 'index_addressed_issues_on_case_conference_domain_id'
  end
end
