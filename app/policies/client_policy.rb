class ClientPolicy < ApplicationPolicy
  def create?
    record.status != 'Exited'
  end

  def show_legal_doc?
    fields = [
      :national_id,
      :birth_cert,
      :family_book,
      :passport,
      :travel_doc,
      :referral_doc,
      :local_consent,
      :police_interview,
      :other_legal_doc
    ]

    field_settings.where(name: fields).any? && fields.any?{ |field| show?(field) }
  end

  def brc_client_address?
    fields = %w(current_island current_street current_po_box current_settlement current_resident_own_or_rent current_household_type)
    field_settings.where(name: fields).any? && fields.any?{ |field| show?(field.to_sym) }
  end

  def brc_client_other_address?
    fields = %w(island2 street2 po_box2 settlement2 resident_own_or_rent2 household_type2)
    field_settings.where(name: fields).any? && fields.any?{ |field| show?(field.to_sym) }
  end

  def client_stackholder_contacts?
    field_settings.where(name: Client::STACKHOLDER_CONTACTS_FIELDS).any? &&
    Client::STACKHOLDER_CONTACTS_FIELDS.any?{ |field| show?(field) }
  end

  def client_school_information?
    fields = [
      :school_name,
      :school_grade,
      :main_school_contact,
      :education_background
    ]

    field_settings.where(name: fields).any? && fields.any?{ |field| show?(field) }
  end

  def show?(*field_names)
    return true if field_names.blank?
    field = field_names.first.to_s

    hidden_fields = %w(
      province donor_info kid_id carer
      custom_id1 custom_id2 carer_info custom_ids school_info referee_info
      school_name school_grade main_school_contact donor referee care
      current_address house_number street_number village commune district province_id
      code concern_province_id concern_district_id concern_commune_id concern_village_id
      concern_street concern_house concern_address concern_address_type
      concern_phone concern_phone_owner concern_email concern_email_owner
      concern_same_as_client location_description
      referee_name referee_phone referee_email carer_name carer_phone carer_email
      client_contact_phone address_type birth_province_id telephone_number live_with
    )

    return false if Organization.brc? && (hidden_fields.include?(field) || hidden_fields.map{|f| f + '_'}.include?(field))


    field_setting = field_settings.find do |field_setting|
      field_setting.name == field &&
      field_setting.klass_name == 'client' &&
      (field_setting.for_instances.blank? || field_setting.for_instances.include?(Organization.current&.short_name))
    end

    field_setting.present? ? (field_setting.required? || field_setting.visible?) : true
  end
end
