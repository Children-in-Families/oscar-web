class AddFieldTrackingFormEditDurationToSetting < ActiveRecord::Migration
  def change
    add_column :settings, :tracking_form_edit_limit, :integer, default: 0
    add_column :settings, :tracking_form_edit_frequency, :string, default: 'week'
  end
end
