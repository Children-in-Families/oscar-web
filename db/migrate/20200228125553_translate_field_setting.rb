class TranslateFieldSetting < ActiveRecord::Migration[5.2]
  def change
    reversible do |dir|
      dir.up do
        FieldSetting.create_translation_table! :label => :string
      end

      dir.down do
        FieldSetting.drop_translation_table!
      end
    end
  end
end
