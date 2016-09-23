class AddAlertManagerFieldToAbleScreeningQuestion < ActiveRecord::Migration
  def change
    add_column :able_screening_questions, :alert_manager, :boolean
  end
end
