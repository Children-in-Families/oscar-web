class AddGenderToFamilyMembers < ActiveRecord::Migration
  def change
    add_column :family_members, :gender, :string
  end
end
