class AddCustomCsiNameToSettings < ActiveRecord::Migration
  def up
    add_column :settings, :custom_assessment, :string, default: 'Custom Assessment'
    add_column :settings, :enable_custom_assessment, :boolean, default: false
    add_column :settings, :enable_default_assessment, :boolean, default: true
    add_column :settings, :max_custom_assessment, :integer, default: 6
    add_column :settings, :custom_assessment_frequency, :string, default: 'month'
    add_column :settings, :custom_age, :integer, default: 18
    add_column :settings, :default_assessment, :string, default: 'CSI Assessment'
    change_column :settings, :max_assessment, :integer, default: 6
    change_column :settings, :assessment_frequency, :string, default: 'month'

    Setting.first.update(enable_custom_assessment: false, enable_default_assessment: false) if Setting.first.disable_assessment?

    Setting.first.update(enable_custom_assessment: true, enable_default_assessment: false) if ['mho', 'fsc', 'tlc'].include?(Organization.current.try(:short_name))

    remove_column :settings, :disable_assessment, :boolean, default: true
  end

  def down
    remove_column :settings, :custom_assessment, :string, default: 'Custom Assessment'
    remove_column :settings, :enable_custom_assessment, :boolean, default: false
    remove_column :settings, :enable_default_assessment, :boolean, default: true
    remove_column :settings, :max_custom_assessment, :integer, default: 6
    remove_column :settings, :custom_assessment_frequency, :string, default: 'month'
    remove_column :settings, :custom_age, :integer, default: 18
    remove_column :settings, :default_assessment, :string, default: 'CSI Assessment'
    change_column :settings, :max_assessment, :integer, default: nil
    change_column :settings, :assessment_frequency, :string, default: nil

    add_column :settings, :disable_assessment, :boolean, defalut: false
  end
end
