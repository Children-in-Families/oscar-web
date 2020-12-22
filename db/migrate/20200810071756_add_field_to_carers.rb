class AddFieldToCarers < ActiveRecord::Migration[5.2]
  def change
    add_column :carers, :locality, :string
  end
end
