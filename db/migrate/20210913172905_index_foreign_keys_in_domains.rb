class IndexForeignKeysInDomains < ActiveRecord::Migration
  def change
    add_index :domains, :custom_assessment_setting_id
  end
end
