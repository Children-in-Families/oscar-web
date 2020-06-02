class UpdateGenderSetting < ActiveRecord::Migration
  def up
    FieldSetting.where(name: :gender, klass_name: :client).update_all(required: true)
  end

  def down;end
end
