class CustomFieldNumericalityValidator < ActiveModel::Validator

  def initialize(record)
    @record = record
  end

  def validate
    return unless @record.properties
    @record.custom_field.field_objs.each do |field|
      if field['type'] == 'number' && (field['min'].present? || field['max'].present?)
        if @record.properties_objs[field['name']].to_f < field['min'].to_f
          @record.errors.add(field['name'], "can't be lower then #{field['min']}")
        elsif @record.properties_objs[field['name']].to_f > field['max'].to_f
          @record.errors.add(field['name'], "can't be greater then #{field['max']}")
        end
      end
    end
  end
end
