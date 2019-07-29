class AddDefaultAssessmentsCountCustomAssessmentsCountToClients < ActiveRecord::Migration
  def self.up
    add_column :clients, :default_assessments_count, :integer, null: false, default: 0
    add_column :clients, :custom_assessments_count, :integer, null: false, default: 0

    execute <<-SQL.squish
        UPDATE clients SET default_assessments_count = (SELECT count(1)
                          FROM assessments WHERE assessments.client_id = clients.id AND assessments.default = true),
                       custom_assessments_count  = (SELECT count(1)
                          FROM assessments WHERE assessments.client_id = clients.id AND assessments.default = false)
    SQL
  end

  def self.down
    remove_column :clients, :default_assessments_count
    remove_column :clients, :custom_assessments_count
  end
end
