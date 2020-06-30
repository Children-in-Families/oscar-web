class AddTaskableToTask < ActiveRecord::Migration
  def change
    add_reference :tasks, :taskable, polymorphic: true, index: true

    reversible do |dir|
      dir.up do
        Task.with_deleted.by_case_note.each do |task|
          next if task.case_note_id.blank?
          task.taskable_id = task.case_note_id&.to_i
          task.taskable_type = 'CaseNote'
          task.save
        end
      end
    end
  end
end
