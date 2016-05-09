class CreateGovernmentReportsQuantitativeCases < ActiveRecord::Migration
  def change
    create_table :government_reports_quantitative_cases do |t|
    	t.belongs_to :government_report
    	t.belongs_to :quantitative_case

    	t.timestamps
    end
  end
end
