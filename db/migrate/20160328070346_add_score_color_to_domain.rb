class AddScoreColorToDomain < ActiveRecord::Migration[5.2]
  def change
    add_column :domains, :score_1_color, :string, default: 'danger'
    add_column :domains, :score_2_color, :string, default: 'warning'
    add_column :domains, :score_3_color, :string, default: 'info'
    add_column :domains, :score_4_color, :string, default: 'success'
  end
end
