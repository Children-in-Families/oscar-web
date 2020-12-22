class AddGuardianToFamilyMember < ActiveRecord::Migration[5.2]
  def change
    add_column :family_members, :guardian, :boolean, default: false
  end
end
