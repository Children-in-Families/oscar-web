class ChangeDefaultValueOfDomainFourScore < ActiveRecord::Migration
  def change
    change_column :domains, :score_4_color, :string, default: 'primary'
  end
end
