class CustomFieldNumericalityValidator < ActiveModel::Validator

  def initialize(record)
    @record = record
    @properties = JSON.parse(@record.properties)
  end

  def validate
    CustomField.find_by(entity_name: @record.class.name).field_objs.each do |field|
      if field['type'] == 'number' && (field['min'].present? || field['max'].present?)
        if @properties[field['name']].to_f < field['min'].to_f
          @record.errors.add(field['name'], "can't be lower then #{field['min']}")
        elsif @properties[field['name']].to_f > field['max'].to_f
          @record.errors.add(field['name'], "can't be greater then #{field['max']}")
        end
      end
    end
  end
end
