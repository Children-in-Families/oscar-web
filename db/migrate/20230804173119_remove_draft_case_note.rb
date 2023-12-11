class RemoveDraftCaseNote < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        begin
          CaseNote.unscoped do
            CaseNote.draft.destroy_all
          end
        rescue => e
          puts e.message
        end
      end
    end
  end
end
