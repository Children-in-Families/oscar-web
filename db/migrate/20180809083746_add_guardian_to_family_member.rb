class AddGuardianToFamilyMember < ActiveRecord::Migration
  def change
    add_column :family_members, :guardian, :boolean, default: false
  end
end
