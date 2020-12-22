class ChangeColumnProvinces < ActiveRecord::Migration[5.2]
  def change
    change_column_null :provinces, :users_count, false
    Province.find_each do |province|
      Province.reset_counters(province.id, :users)
    end
  end
end
