class CustomFormEmailValidator < ActiveModel::Validator

  def initialize(record,table_name,field)
    @record     = record
    @table_name = table_name
    @field      = field
  end

  def validate
    return unless @record.properties.present?
    @record.send(@table_name).send(@field).each do |field|
      next if field['subtype'] != 'email' || (field['subtype'] == 'email' && @record.properties[field['label']].empty?)
      unless @record.properties[field['label']] =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
        @record.errors.add(field['label'], I18n.t('is_not_email')) if @record.errors[field['label']].empty?
      end
    end
  end
end
