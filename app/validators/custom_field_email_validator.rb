class CustomFieldEmailValidator < ActiveModel::Validator

  def initialize(record)
    @record = record
  end

  def validate
    return unless @record.properties
    @record.custom_field.fields.each do |field|
      next if field['subtype'] != 'email'
      unless @record.properties[field['label']] =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
        @record.errors.add(field['label'], I18n.t('is_not_email')) if @record.errors[field['label']].empty?
      end
    end
  end
end
