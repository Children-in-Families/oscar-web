module ClientsHelper
  def user(user)
    if can? :read, User
      link_to user.name, user_path(user) if user.present?
    elsif user.present?
      user.name
    end
  end

  def order_case_worker(client)
    client.users.order("lower(first_name)", "lower(last_name)")
  end

  def partner(partner)
    if can? :manage, :all
      link_to partner.name, partner_path(partner)
    else
      partner.name
    end
  end

  def family(family)
    family_name = family.name.present? ? family.name : 'Unknown'
    if can? :manage, :all
      link_to family_name, family_path(family)
    else
      family_name
    end
  end

  def able_screen_link(client)
    if client.answers.any?
      link_to '', 'data-target': '#clientAnswer', 'data-toggle': :modal, type: :button do
        content_tag(:span, t('.client_able_answers'), class: 'btn btn-sm btn-warning small-btn-margin')
      end
    else
      return content_tag(:span, t('.able_screening_questions'), class: 'btn btn-sm btn-warning small-btn-margin disabled') if client.date_of_birth.blank?
      link_to able_screens_answer_submissions_client_able_screening_answers_new_path(client) do
        content_tag(:span, t('.able_screening_questions'), class: "btn btn-sm btn-warning small-btn-margin #{'disabled' if client.date_of_birth.blank?}")
      end
    end
  end

  def report_options(title, yaxis_title)
    {
      library: {
        legend: {
          verticalAlign: 'top',
          y: 30
        },
        tooltip: {
          shared: true,
          xDateFormat: '%b %Y'
        },
        title: {
          text: title
        },
        xAxis: {
          dateTimeLabelFormats: {
            month: '%b %Y'
          },
          tickmarkPlacement: 'on'
        },
        yAxis: {
          allowDecimals: false,
          title: {
            text: yaxis_title
          }
        }
      }
    }
  end

  def columns_visibility(column)
    label_column = {
      slug:                          t('datagrid.columns.clients.id'),
      kid_id:                        t('datagrid.columns.clients.kid_id'),
      code:                          t('datagrid.columns.clients.code'),
      case_type:                     t('datagrid.columns.clients.case_type'),
      age:                           t('datagrid.columns.clients.age'),
      given_name:                    t('datagrid.columns.clients.given_name'),
      family_name:                   t('datagrid.columns.clients.family_name'),
      local_given_name:              t('datagrid.columns.clients.local_given_name'),
      local_family_name:             t('datagrid.columns.clients.local_family_name'),
      gender:                        t('datagrid.columns.clients.gender'),
      date_of_birth:                 t('datagrid.columns.clients.date_of_birth'),
      birth_province_id:             t('datagrid.columns.clients.birth_province'),
      status:                        t('datagrid.columns.clients.status'),
      received_by_id:                t('datagrid.columns.clients.received_by'),
      followed_up_by_id:             t('datagrid.columns.clients.follow_up_by'),
      initial_referral_date:         t('datagrid.columns.clients.initial_referral_date'),
      referral_phone:                t('datagrid.columns.clients.referral_phone'),
      referral_source_id:            t('datagrid.columns.clients.referral_source'),
      follow_up_date:                t('datagrid.columns.clients.follow_up_date'),
      agencies_name:                 t('datagrid.columns.clients.agencies_involved'),
      province_id:                   t('datagrid.columns.clients.current_province'),
      current_address:               t('datagrid.columns.clients.current_address'),
      house_number:                  t('datagrid.columns.clients.house_number'),
      street_number:                 t('datagrid.columns.clients.street_number'),
      village:                       t('datagrid.columns.clients.village'),
      commune:                       t('datagrid.columns.clients.commune'),
      district:                      t('datagrid.columns.clients.district'),
      school_name:                   t('datagrid.columns.clients.school_name'),
      grade:                         t('datagrid.columns.clients.school_grade'),
      able_state:                    t('datagrid.columns.clients.able_state'),
      has_been_in_orphanage:         t('datagrid.columns.clients.has_been_in_orphanage'),
      has_been_in_government_care:   t('datagrid.columns.clients.has_been_in_government_care'),
      relevant_referral_information: t('datagrid.columns.clients.relevant_referral_information'),
      user_ids:                      t('datagrid.columns.clients.case_worker'),
      state:                         t('datagrid.columns.clients.state'),
      family_id:                     t('datagrid.columns.clients.family_id'),
      any_assessments:               t('datagrid.columns.clients.assessments'),
      donor:                         t('datagrid.columns.clients.donor'),
      changelog:                     t('datagrid.columns.clients.changelog'),
      live_with:                     t('datagrid.columns.clients.live_with'),
      id_poor:                       t('datagrid.columns.clients.id_poor'),
    }
    label_tag "#{column}_", label_column[column.to_sym]
  end

  def case_button(type)
    link_to new_client_case_path(@client, case_type: type) do
      content_tag(:span, '') do
        content_tag(:span, t(".add_#{type.downcase}_btn"), class: 'text-success')
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

  def can_read_client_progress_note?
    @client.able? && (current_user.case_worker? || current_user.able_manager? || current_user.admin? || current_user.fc_manager? || current_user.manager? || current_user.kc_manager? || current_user.strategic_overviewer?)
  end

  def disable_case_histories?
    'disabled' if current_user.able_manager?
  end

  def client_custom_fields_list(object)
    content_tag(:ul, class: 'client-custom-fields-list') do
      object.custom_fields.uniq.each do |obj|
        concat(content_tag(:li, obj.form_title))
      end
    end
  end

  def merged_address(client)
    current_address = []
    current_address << "#{I18n.t('datagrid.columns.clients.house_number')} #{client.house_number}" if client.house_number.present?
    current_address << "#{I18n.t('datagrid.columns.clients.street_number')} #{client.street_number}" if client.street_number.present?
    current_address << "#{I18n.t('datagrid.columns.clients.village')} #{client.village}" if client.village.present?
    current_address << "#{I18n.t('datagrid.columns.clients.commune')} #{client.commune}" if client.commune.present?
    current_address << "#{I18n.t('datagrid.columns.clients.district')} #{client.district}" if client.district.present?
    if locale == :km
      current_address << client.province.name.split(' / ').first if client.province.present?
    else
      current_address << client.province.name.split(' / ').last if client.province.present?
    end
    current_address << I18n.t('datagrid.columns.clients.cambodia')
    current_address.compact.join(', ')
  end

  def format_properties_value(value)
    value.is_a?(Array) ? value.join(', ') : value 
  end
end
