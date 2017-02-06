class CustomFieldPresentValidator < ActiveModel::Validator

  def initialize(record)
    @record = record
  end

  def validate
    return unless @record.properties
    @record.custom_field.field_objs.each do |field|
      if field['required'] && @record.properties_objs[field['name']].blank?
        @record.errors.add(field['name'], "can't be blank")
      end
    end
  end
end
