class MovePropertyToFieldInCustomField < ActiveRecord::Migration[5.2]
  def change
    puts '==========Processing=========='

    CustomField.all.each do |custom_field|
      property = custom_field.properties.present? ? custom_field.properties : '[]'
      custom_field.update_columns(fields: eval(property))
    end

    puts '==========Done=========='
  end
end
