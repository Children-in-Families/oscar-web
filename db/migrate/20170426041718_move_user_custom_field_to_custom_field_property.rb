class MoveUserCustomFieldToCustomFieldProperty < ActiveRecord::Migration
  def change
    puts '==========Processing=========='

    UserCustomField.all.each do |user_custom_field|
      property = user_custom_field.properties == ('null' || '') ? '{}' : user_custom_field.properties

      user_custom_field_property = CustomFieldProperty.new(
        properties: eval(property),
        custom_formable_id: user_custom_field.user_id,
        custom_formable_type: 'User',
        custom_field_id: user_custom_field.custom_field_id
       )

       if family_custom_field_property.save
         puts 'Successed'
       else
         puts "Failed to move on #{user_custom_field_property.properties} "
       end
    end

    puts '==========Done=========='

    drop_table :user_custom_fields
  end
end
