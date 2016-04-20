module ClientsHelper

  def user(user)
    if can? :manage, :all
      link_to user.name, user_path(user)
    else
      user.name
    end
  end

  def partner(partner)
    if can? :manage, :all
      link_to partner.name, partner_path(partner)
    else
      partner.name
    end
  end

  def family(family)
    if can? :manage, :all
      link_to family.name, family_path(family)
    else
      family.name
    end
  end

  def columns_visibility(column)
    label_tag "#{column}_",
      case column
      when :first_name                    then 'Name'
      when :gender                        then 'Gender'
      when :date_of_birth                 then 'Date of Birth'
      when :birth_province_id             then 'Birth Province'
      when :status                        then 'Status'
      when :received_by_id                then 'Received By'
      when :followed_up_by_id             then 'Followed Up By'
      when :initial_referral_date         then 'Initial Referral Date'
      when :referral_phone                then 'Referral Phone'
      when :referral_source_id            then 'Referral Source'
      when :follow_up_date                then 'Follow Up Date'
      when :agencies_name                 then 'Agencies Involved'
      when :province_id                   then 'Current Province'
      when :current_address               then 'Current Address'
      when :school_name                   then 'School Name'
      when :grade                         then 'School Grade'
      when :able                          then 'Able?'
      when :has_been_in_orphanage         then 'Has Been In Orphanage?'
      when :has_been_in_government_care   then 'Has Been In Government Care?'
      when :relevant_referral_information then 'Relevant Referral Information'
      when :user_id                       then 'Case Worker / Staff'
      when :state                         then 'State'
      end
  end

  def case_button(type)
    link_to new_client_case_path(@client, case_type: type) do
      content_tag(:div, '', class: 'col-xs-10 col-xs-offset-1 btn btn-success pushing-bottom') do
        content_tag(:h4, t(".add_#{type.downcase}_btn"))
      end
    end
  end

  def ec_manageable
    current_user.admin? || current_user.case_worker? || current_user.ec_manager?
  end

  def fc_manageable
    current_user.admin? || current_user.case_worker? || current_user.fc_manager?
  end

  def kc_manageable
    current_user.admin? || current_user.case_worker? || current_user.kc_manager?
  end

  def link_to_add_fields(name, f, association, task_builder)
    domain     = task_builder.object.domain
    new_object = f.object.send(association).klass.new
    id         = new_object.object_id
    fields     = f.fields_for(association, new_object, child_index: id) do |builder|
      render(association.to_s.singularize + '_fields', f: builder, domain: domain)
    end
    link_to(name, '#', class: 'btn btn-default add_fields pull-right', data: { id: id, fields: fields.gsub('\n', '')})
  end

end