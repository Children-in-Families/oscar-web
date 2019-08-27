class DisAttachDomainGroup < ActiveRecord::Migration
  def up
    create_table "old_case_note_domain_groups", force: :cascade do |t|
      t.text     "note",            default: ""
      t.integer  "case_note_id"
      t.integer  "domain_group_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "attachments",     default: [], array: true
    end

    execute <<-SQL.squish
      INSERT INTO old_case_note_domain_groups SELECT * FROM case_note_domain_groups WHERE attachments = '{}' OR note = '';
      DELETE FROM case_note_domain_groups WHERE attachments = '{}' OR note = '';
    SQL
  end

  def down
    execute <<-SQL.squish
      INSERT INTO case_note_domain_groups SELECT * FROM old_case_note_domain_groups;
      DROP TABLE old_case_note_domain_groups CASCADE;
    SQL
  end
end
