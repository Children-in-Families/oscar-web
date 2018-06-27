class ChangeConsentFormColumnType < ActiveRecord::Migration
  def up
    change_column :referrals, :consent_form, :string, array: true, default: [], using: "(string_to_array(consent_form, ','))"
  end

  def down
    change_column :referrals, :consent_form, :string, array: false, default: nil, using: "(array_to_string(consent_form, ','))"
  end
end
