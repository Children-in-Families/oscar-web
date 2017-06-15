class FamilySerializer < ActiveModel::Serializer
  attributes :id, :name, :code, :case_history, :caregiver_information, :significant_family_member_count, :household_income, :dependable_income, :female_children_count, :male_children_count, :female_adult_count, :male_adult_count, :family_type, :contract_date, :address, :province, :clients

  def clients
    object.clients.map do |client|
      formatted_client = client.as_json(except: [:birth_province_id, :received_by_id, :followed_up_by_id, :province_id, :referral_source_id, :donor_id])

      formatted_client.merge!(birth_province:   client.birth_province.as_json(only: [:id, :name]))
      formatted_client.merge!(received_by:      client.received_by.as_json(only: [:id, :first_name, :last_name]))
      formatted_client.merge!(followed_up_by:   client.followed_up_by.as_json(only: [:id, :first_name, :last_name]))
      formatted_client.merge!(province:         client.province.as_json(only: [:id, :name]))
      formatted_client.merge!(referral_source:  client.referral_source.as_json(only: [:id, :name]))
      formatted_client.merge!(donor:            client.donor_name)
      formatted_client.merge!(current_case:     CaseSerializer.new(client.cases.current).serializable_hash.as_json(except: [:user, :family]))
      formatted_client.merge!(assessments:      client.assessments)
      formatted_client.merge!(form_title:       client.custom_fields.pluck(:form_title).uniq.join(', '))
    end
  end
end