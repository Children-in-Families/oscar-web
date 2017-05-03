class MoveClientCustomFieldToCustomFieldProperty < ActiveRecord::Migration
  def change
    puts '==========Processing=========='

    ClientCustomField.all.each do |client_custom_field|
      property = client_custom_field.properties.present? ? client_custom_field.properties : '{}'

      client_custom_field_property = CustomFieldProperty.new(
        properties: eval(property),
        custom_formable_id: client_custom_field.client_id,
        custom_formable_type: 'Client',
        custom_field_id: client_custom_field.custom_field_id
       )
       if client_custom_field_property.save
         puts 'Successed'
       else
         puts "Failed to move on #{client_custom_field_property.properties} "
       end
    end

    puts '==========Done=========='

    drop_table :client_custom_fields
  end
end
