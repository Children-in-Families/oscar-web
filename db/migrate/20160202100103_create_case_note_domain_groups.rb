class CreateCaseNoteDomainGroups < ActiveRecord::Migration
  def change
    create_table :case_note_domain_groups do |t|
      t.text       :note, default: ''

      t.references :case_note
      t.references :domain_group

      t.timestamps
    end
  end
end
