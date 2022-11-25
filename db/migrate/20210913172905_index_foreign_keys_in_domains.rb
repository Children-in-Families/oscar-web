class IndexForeignKeysInDomains < ActiveRecord::Migration[5.2]
  def change
    add_index :domains, :custom_assessment_setting_id
  end
end
