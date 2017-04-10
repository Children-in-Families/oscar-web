class CustomFieldPresentValidator < ActiveModel::Validator
  def initialize(record)
    @record = record
  end

  def validate
    return unless @record.properties
    @record.custom_field.field_objs.each do |field|
      if field['required'] && (@record.properties_objs[field['label']].blank? || @record.properties_objs[field['label']][0].blank?)
        @record.errors.add(field['label'], I18n.t('cannot_be_blank'))
      end
    end
  end
end
