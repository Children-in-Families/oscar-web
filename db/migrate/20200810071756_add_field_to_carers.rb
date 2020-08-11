class AddFieldToCarers < ActiveRecord::Migration
  def change
    add_column :carers, :locality, :string
  end
end
