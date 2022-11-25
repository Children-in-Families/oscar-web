class ChangeDataTypeOfGovernmentForms < ActiveRecord::Migration[5.2]
  def up
    change_column :government_forms, :source_info, :text, :default => ''
    change_column :government_forms, :summary_info_of_referral, :text, :default => ''
    change_column :government_forms, :guardian_comment, :text, :default => ''
    change_column :government_forms, :case_worker_comment, :text, :default => ''
    change_column :government_form_children_plans, :goal, :text, :default => ''
    change_column :government_form_children_plans, :action, :text, :default => ''
    change_column :government_form_children_plans, :who, :text, :default => ''
    change_column :government_form_family_plans, :goal, :text, :default => ''
    change_column :government_form_family_plans, :action, :text, :default => ''
    change_column :government_form_family_plans, :result, :text, :default => ''
  end

  def down
    change_column :government_forms, :source_info, :string, :default => ''
    change_column :government_forms, :summary_info_of_referral, :string, :default => ''
    change_column :government_forms, :guardian_comment, :string, :default => ''
    change_column :government_forms, :case_worker_comment, :string, :default => ''
    change_column :government_form_children_plans, :goal, :string, :default => ''
    change_column :government_form_children_plans, :action, :string, :default => ''
    change_column :government_form_children_plans, :who, :string, :default => ''
    change_column :government_form_family_plans, :goal, :string, :default => ''
    change_column :government_form_family_plans, :action, :string, :default => ''
    change_column :government_form_family_plans, :result, :string, :default => ''
  end
end
