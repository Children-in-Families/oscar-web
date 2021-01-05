class AddAssessmentScoreOrderToSettings < ActiveRecord::Migration[5.2]
  def change
    add_column :settings, :assessment_score_order, :string, default: 'random_order', null: false
  end
end
