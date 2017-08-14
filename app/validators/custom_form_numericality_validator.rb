class CustomFormNumericalityValidator < ActiveModel::Validator

  def initialize(record,table_name,field)
    @record     = record
    @table_name = table_name
    @field      = field
  end

  def validate
    return unless @record.properties
    @record.send(@table_name).send(@field).each do |field|
      next unless field['type'] == 'number' && (field['min'].present? || field['max'].present?) && @record.properties[field['label']].present?
      if @record.properties[field['label']].to_f < field['min'].to_f
        @record.errors.add(field['label'], I18n.t('cannot_be_lower', count: field['min'])) if @record.errors[field['label']].empty?
      elsif @record.properties[field['label']].to_f > field['max'].to_f
        @record.errors.add(field['label'], I18n.t('cannot_be_greater', count: field['max'])) if @record.errors[field['label']].empty?
      end
    end
  end
end
