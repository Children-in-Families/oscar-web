class MovePartnerCustomFieldToCustomFieldProperty < ActiveRecord::Migration
  def change
    puts '==========Processing=========='

    PartnerCustomField.all.each do |partner_custom_field|
      property = partner_custom_field.properties == ('null' || '') ? '{}' : partner_custom_field.properties

      partner_custom_field_property = CustomFieldProperty.new(
        properties: eval(property),
        custom_formable_id: partner_custom_field.partner_id,
        custom_formable_type: 'Partner',
        custom_field_id: partner_custom_field.custom_field_id
       )

       if family_custom_field_property.save
         puts 'Successed'
       else
         puts "Failed to move on #{partner_custom_field_property.properties} "
       end
    end

    puts '==========Done=========='

    drop_table :partner_custom_fields
  end
end
