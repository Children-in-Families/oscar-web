module AdvancedSearchFieldHelper
  def received_by_options(klass_name = 'Client')
    Rails.cache.fetch([Apartment::Tenant.current, klass_name, 'received_by', @user.id]) do
      recevied_by_clients = @user.admin? || @user.manager? ? klass_name.constantize.is_received_by : klass_name.constantize.where(user_id: @user.id).is_received_by
      recevied_by_clients.sort.map { |s| { s[1].to_s => s[0] } }
    end
  end

  def followed_up_by_options(klass_name = 'Client')
    Rails.cache.fetch([Apartment::Tenant.current, klass_name, 'followed_up_by', @user.id]) do
      followed_up_clients = @user.admin? || @user.manager? ? klass_name.constantize.is_followed_up_by : klass_name.constantize.where(user_id: @user.id).is_followed_up_by
      followed_up_clients.sort.map { |s| { s[1].to_s => s[0] } }
    end
  end

  def created_by_options(klass_name = 'Client')
    created_by_objects = @user.admin? || @user.manager? ? klass_name.constantize.is_created_by : klass_name.constantize.where(user_id: @user.id).is_created_by
    created_by_objects.sort.map { |s| { s[1].to_s => s[0] } }
  end


  def referral_source_category_options(klass_name = 'Client')
    return [] if klass_name.constantize.count.zero?
    ref_cat_ids = klass_name.constantize.pluck(:referral_source_category_id).compact.uniq

    ReferralSource.cache_all.map do |item|
      { item.id.to_s => I18n.locale == :km ? item.name : item.name_en } if item.id.in?(ref_cat_ids)
    end.compact.sort_by { |h| h.values.first }
  end

  def referral_source_options(klass_name = 'Client')
    referral_sources = @user.admin? ? klass_name.constantize.referral_source_is : klass_name.constantize.where(user_id: @user.id).referral_source_is
    referral_sources.sort.map { |s| { s[1].to_s => s[0] } }
  end

  def mapping_care_plan_date_lable_translation
    care_plan_group = format_header('care_plan')
    care_plan_date_fields.map { |item| AdvancedSearches::FilterTypes.date_picker_options(item, format_header(item), care_plan_group) }
  end

  def care_plan_date_fields
    ['care_plan_date', 'care_plan_completed_date']
  end
end
