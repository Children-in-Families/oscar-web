class MoveFamilyCustomFieldToCustomFieldProperty < ActiveRecord::Migration
  def change
    puts '==========Processing=========='

    FamilyCustomField.all.each do |family_custom_field|
      property = family_custom_field.properties.present? ? family_custom_field.properties : '{}'

      family_custom_field_property = CustomFieldProperty.new(
        properties: eval(property),
        custom_formable_id: family_custom_field.family_id,
        custom_formable_type: 'Family',
        custom_field_id: family_custom_field.custom_field_id
       )

       if family_custom_field_property.save
         puts 'Successed'
       else
         puts "Failed to move on #{family_custom_field_property.properties} "
       end
    end

    puts '==========Done=========='

    drop_table :family_custom_fields
  end
end
