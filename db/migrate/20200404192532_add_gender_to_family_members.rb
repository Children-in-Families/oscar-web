class AddGenderToFamilyMembers < ActiveRecord::Migration[5.2]
  def change
    add_column :family_members, :gender, :string
  end
end
