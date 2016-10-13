module VersionHelper
  def version_attribute(k)
    k = k == 'first_name' ? 'name' : k
    k.titleize
  end

  def version_value_format(val, k = '', both_val = [])
    provinces        = ['birth_province_id', 'province_id']
    referral_sources = ['referral_source_id']
    users            = ['received_by_id', 'followed_up_by_id', 'user_id']
    booleans         = ['has_been_in_orphanage', 'has_been_in_government_care', 'able']

    if k == 'gender' || k == 'state'
      if val == both_val[0]
        val  = both_val[0].downcase == both_val[1].downcase ? '' : val.titleize
      else
        val  = val.titleize
      end
    elsif val.class == Date
      val = val.strftime('%d %B, %Y')
    elsif val.class == ActiveSupport::TimeWithZone
      val = val.in_time_zone.strftime('%d %B, %Y %H:%M:%S')
    elsif provinces.include?(k)
      val = Province.find(val).name if val.present?
    elsif referral_sources.include?(k)
      val = ReferralSource.find(val).name if val.present?
    elsif users.include?(k)
      val = User.find(val).name if val.present?
    elsif booleans.include?(k)
      val = human_boolean(val)
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
end