class AddCustomCsiNameToSettings < ActiveRecord::Migration
  def up
    add_column :settings, :customized_assessment_name, :string, default: 'Custom CSI'
    add_column :settings, :enable_customized_assessment, :boolean, default: false
    add_column :settings, :enable_default_assessment, :boolean, default: true
    add_column :settings, :default_max_assessment, :integer, default: 6
    add_column :settings, :default_assessment_frequency, :string, default: 'month'
    add_column :settings, :default_age, :integer, default: 18
    add_column :settings, :default_assessment_name, :string, default: 'Default CSI'

    Setting.first.update(enable_customized_assessment: false, enable_default_assessment: false) if Setting.first.disable_assessment?

    Setting.first.update(enable_customized_assessment: true, enable_default_assessment: false) if ['mho' 'fsc' 'tlc'].include?(Organization.current.try(:short_name))

    remove_column :settings, :disable_assessment, :boolean, default: true
  end

  def down
    remove_column :settings, :customized_assessment_name, :string, default: 'Custom CSI'
    remove_column :settings, :enable_customized_assessment, :boolean, default: false
    remove_column :settings, :enable_default_assessment, :boolean, default: true
    remove_column :settings, :default_max_assessment, :integer, default: 6
    remove_column :settings, :default_assessment_frequency, :string, default: 'month'
    remove_column :settings, :default_age, :integer, default: 18
    remove_column :settings, :default_assessment_name, :string, default: 'Default CSI'

    add_column :settings, :disable_assessment, :boolean, defalut: false
  end
end
