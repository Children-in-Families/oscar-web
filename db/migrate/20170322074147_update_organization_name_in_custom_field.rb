class UpdateOrganizationNameInCustomField < ActiveRecord::Migration[5.2]
  def change
    unprocessable_custom_fields = []

    puts '==========Processing=========='

    CustomField.find_each do |custom_field|
      begin
        if custom_field.ngo_name.blank?
          custom_field.update_attributes!(ngo_name: Organization.current.full_name)
        end
      rescue
        unprocessable_custom_fields << custom_field.id
      end
    end
    puts '==========Done=========='

    system "echo #{unprocessable_custom_fields} >> error.txt" if unprocessable_custom_fields.present?
  end
end
