class PopulateClientAssessmentsCount < ActiveRecord::Migration[5.2]
  def change
    remove_column :clients, :assessments_count, :integer
    add_column :clients, :assessments_count, :integer, default: 0, null: false
    Client.find_each do |client|
      Client.reset_counters(client.id, :assessments)
    end
  end
end
