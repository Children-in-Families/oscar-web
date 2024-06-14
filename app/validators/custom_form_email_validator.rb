class CustomFormEmailValidator < ActiveModel::Validator
  def initialize(record, table_name, field)
    @record = record
    @table_name = table_name
    @field = field
  end

  def validate
    return unless @record.properties.present?
    @record.send(@table_name).send(@field).each do |field|
      field_label = field['name']
      next if field['subtype'] != 'email' || (field['subtype'] == 'email' && @record.properties[field_label].empty?)
      unless @record.properties[field_label] =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
        @record.errors.add(field_label, I18n.t('is_not_email')) if @record.errors[field_label].empty?
      end
    end
  end
end
