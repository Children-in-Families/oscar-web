module VersionHelper
  def version_attribute(k, item_type = '')
    if k == 'first_name' && item_type == 'Client'
      k = 'name'
    elsif k == 'change_version'
      k = 'version'
    elsif k == 'name' && item_type == 'Task'
      k = 'task detail'
    elsif k == 'attendee'
      k = 'present'
    elsif k == 'listening_score'
      k = 'I feel like my CCW listens to me when I speak.'
    elsif k == 'problem_solving_score'
      k = 'My CCW helps me solve my problems.'
    elsif k == 'getting_in_touch_score'
      k = 'My CCW knows of other services and groups of people who can help me, and helps me get in touch with them.'
    elsif k == 'trust_score'
      k = 'I can trust my CCW.'
    elsif k == 'difficulty_help_score'
      k = 'CIF has helped me through difficult times in my life.'
    elsif k == 'support_score'
      k = 'CIF has helped me through difficult times in my life.'
    elsif k == 'family_need_score'
      k = 'I am happy with the way CIF and my CCW have supported me.'
    elsif k == 'care_score'
      k = 'My CCW cares about what happens to the children I take care of.'
    elsif k == 'contact_person_name'
      k = 'contact name'
    elsif k == 'contact_person_email'
      k = 'email'
    elsif k == 'contact_person_mobile'
      k = 'contact mobile'
    end
    is_survey_score_text?(k) ? k : k.titleize
  end

  def version_value_format(val, k = '', both_val = [])
    provinces          = ['birth_province_id', 'province_id']
    referral_sources   = ['referral_source_id']
    users              = ['received_by_id', 'followed_up_by_id', 'user_id']
    booleans           = ['has_been_in_orphanage', 'has_been_in_government_care', 'able', 'dependable_income', 'family_preservation', 'exited_from_cif', 'alert_manager']
    titleizeTexts      = ['gender', 'state', 'family_type', 'roles']
    departments        = ['department_id']
    domain_groups      = ['domain_group_id']
    partners           = ['partner_id']
    families           = ['family_id']
    clients            = ['client_id']
    quantitative_types = ['quantitative_type_id']
    domains            = ['domain_id']
    assessments        = ['assessment_id']
    score_colors       = ['score_1_color', 'score_2_color', 'score_3_color', 'score_4_color']

    if titleizeTexts.include?(k)
      if val == both_val[0]
        val  = both_val[0].downcase == both_val[1].downcase ? '' : val.titleize
      else
        val  = val.titleize
      end
    elsif val.class == Date
      val = val.strftime('%d %B, %Y')
    elsif val.class == ActiveSupport::TimeWithZone
      val = val.in_time_zone.strftime('%d %B, %Y %H:%M:%S')
    elsif provinces.include?(k) && val.present?
      val = Province.find(val).name
    elsif referral_sources.include?(k) && val.present?
      val = ReferralSource.find(val).name
    elsif users.include?(k) && val.present?
      val = User.find(val).name
    elsif booleans.include?(k)
      val = human_boolean(val)
    elsif departments.include?(k) && val.present?
      val = Department.find(val).name
    elsif domain_groups.include?(k) && val.present?
      val = DomainGroup.find(val).name
    elsif is_description?(k) && has_html?(val)
      val = strip_tags(val)
    elsif partners.include?(k) && val.present?
      val = Partner.find(val).name
    elsif families.include?(k) && val.present?
      val = Family.find(val).name
    elsif clients.include?(k) && val.present?
      val = Client.find(val).name
    elsif quantitative_types.include?(k) && val.present?
      val = QuantitativeType.find(val).name
    elsif domains.include?(k) && val.present?
      val = Domain.find(val).name
    elsif assessments.include?(k) && val.present?
      val = Assessment.find(val).created_at.in_time_zone.strftime('%d %B, %Y %H:%M:%S')
    elsif score_colors.include?(k)
      val = domain_score_color(val)
    end
    val
  end

  def version_item_type_active?(item_type = '')
    if params[:item_type] || item_type.present?
      'active' if params[:item_type] == item_type
    else
      'active'
    end
  end

  def version_keys_skipable?(k)
    k == 'tokens' || k == 'encrypted_password' || k == 'uid' || k == 'exited' || k == 'able'
  end

  private

  def is_description?(k)
    k == 'description'
  end

  def has_html?(val)
    strip_tags(val) != val
  end

  def domain_score_color(val)
    case val
    when 'danger'  then 'Red'
    when 'info'    then 'Blue'
    when 'success' then 'Green'
    when 'warning' then 'Yellow'
    end
  end

  def is_survey_score_text?(text)
    texts = ['I feel like my CCW listens to me when I speak.',
            'My CCW helps me solve my problems.',
            'My CCW knows of other services and groups of people who can help me, and helps me get in touch with them.',
            'I can trust my CCW.',
            'CIF has helped me through difficult times in my life.',
            'CIF has helped me through difficult times in my life.',
            'I am happy with the way CIF and my CCW have supported me.',
            'My CCW cares about what happens to the children I take care of.']
    texts.include?(text)
  end
end