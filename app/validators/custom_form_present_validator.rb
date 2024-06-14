class CustomFormPresentValidator < ActiveModel::Validator
  def initialize(record, table_name, field)
    @record = record
    @table_name = table_name
    @field = field
  end

  def validate
    return unless @record.properties.present?

    @record.send(@table_name).send(@field).each_with_index do |field, _|
      field_label = I18n.locale.to_s == I18n.default_locale.to_s ? field['name'] : "Local_label #{field['name']}"
      next unless field['required'] && (@record.properties[field_label].blank? || @record.properties[field_label][0].blank?)

      @record.errors.add(field_label, I18n.t('cannot_be_blank')) if field['type'] != 'file'
    end
  end
end
