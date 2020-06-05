class AddAssessmentScoreOrderToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :assessment_score_order, :string, default: 'random_order', null: false
  end
end
