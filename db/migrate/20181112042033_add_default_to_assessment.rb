class AddDefaultToAssessment < ActiveRecord::Migration
 def up
   add_column :assessments, :default, :boolean, default: true
   Assessment.update_all(default: false) if ['mho', 'fsc', 'tlc'].include?(Organization.current.try(:short_name))
 end

 def down
   remove_column :assessments, :default, :boolean, default: true
 end
end
