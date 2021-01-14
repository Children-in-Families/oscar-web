class AddRejectablePolymorphicToExitNgo < ActiveRecord::Migration
  def change
    add_column :exit_ngos, :rejectable_id, :integer
    add_column :exit_ngos, :rejectable_type, :string
  end
end
