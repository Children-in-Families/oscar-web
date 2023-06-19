class FamilySerializer < ActiveModel::Serializer
  attributes :id, :name, :name_en, :code, :case_history, :caregiver_information,
             :significant_family_member_count, :household_income, :dependable_income,
             :female_children_count, :male_children_count, :female_adult_count,
             :male_adult_count, :family_type, :contract_date, :address,
             :province, :district, :commune, :village, :house, :street,
             :clients, :additional_form, :add_forms, :children, :status,
             :slug, :followed_up_by, :follow_up_date, :phone_number, :id_poor,
             :referral_source, :referee_phone_number, :relevant_information, :received_by,
             :initial_referral_date, :referral_source_category, :donor_ids, :case_workers, :quantitative_cases

  has_one :referral_source_category, serializer: ReferralSourceSerializer
  has_one :referral_source

  def clients
    Client.where(id: object.children).map do |client|
      formatted_client = client.as_json(except: [:birth_province_id, :received_by_id, :followed_up_by_id, :province_id, :referral_source_id, :donor_id])

      formatted_client.merge!(birth_province:   client.birth_province.as_json(only: [:id, :name]))
      formatted_client.merge!(received_by:      client.received_by.as_json(only: [:id, :first_name, :last_name]))
      formatted_client.merge!(followed_up_by:   client.followed_up_by.as_json(only: [:id, :first_name, :last_name]))
      formatted_client.merge!(province:         client.province.as_json(only: [:id, :name]))
      formatted_client.merge!(referral_source:  client.referral_source.as_json(only: [:id, :name]))
      formatted_client.merge!(donor:            client.donors.pluck(:name).uniq.join(', '))
      formatted_client.merge!(current_case:     CaseSerializer.new(client.cases.exclude_referred.current).serializable_hash.as_json(except: [:user, :family]))
      formatted_client.merge!(assessments:      client.assessments)
      formatted_client.merge!(form_title:       client.custom_fields.pluck(:form_title).uniq.join(', '))
    end
  end

  def add_forms
    custom_field_ids = object.custom_field_properties.pluck(:custom_field_id)
    CustomField.family_forms.not_used_forms(custom_field_ids).order_by_form_title
  end

  def additional_form
    custom_fields = object.custom_fields.uniq.sort_by(&:form_title)
    custom_fields.map do |custom_field|
      custom_field_property_file_upload = custom_field.custom_field_properties.where(custom_formable_id: object.id)
      custom_field_property_file_upload.each do |custom_field_property|
        custom_field_property.form_builder_attachments.map do |c|
          custom_field_property.properties = custom_field_property.properties.merge({c.name => c.file})
        end
      end
      custom_field.as_json.merge(custom_field_properties: custom_field_property_file_upload.as_json)
    end
  end
end
