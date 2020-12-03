class AddRefereeEmailToReferees < ActiveRecord::Migration
  def change
    add_column :referees, :referee_email, :string
  end
end
