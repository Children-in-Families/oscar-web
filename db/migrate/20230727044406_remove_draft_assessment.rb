class RemoveDraftAssessment < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        begin
          Assessment.unscoped do
            Assessment.draft.destroy_all
          end
        rescue => e
          puts e.message
        end
      end
    end
  end
end
