module AdvancedSearchFieldHelper
  def received_by_options(klass_name = 'Client')
    recevied_by_clients = @user.admin? || @user.manager? ? klass_name.constantize.is_received_by : klass_name.constantize.where(user_id: @user.id).is_received_by
    recevied_by_clients.sort.map { |s| { s[1].to_s => s[0] } }
  end

  def followed_up_by_options(klass_name = 'Client')
    followed_up_clients = @user.admin? || @user.manager? ? klass_name.constantize.is_followed_up_by : klass_name.constantize.where(user_id: @user.id).is_followed_up_by
    followed_up_clients.sort.map { |s| { s[1].to_s => s[0] } }
  end

  def created_by_options(klass_name = 'Client')
    created_by_objects = @user.admin? || @user.manager? ? klass_name.constantize.is_created_by : klass_name.constantize.where(user_id: @user.id).is_created_by
    created_by_objects.sort.map { |s| { s[1].to_s => s[0] } }
  end


  def referral_source_category_options(klass_name = 'Client')
    ref_cat_ids = klass_name.constantize.pluck(:referral_source_category_id).compact.uniq
    if I18n.locale == :km
      ref_cat_kh_names = ReferralSource.where(id: ref_cat_ids).pluck(:name, :id)
      ref_cat_kh_names.sort.map { |s| { s[1].to_s => s[0] } }
    else
      ref_cat_en_names = ReferralSource.where(id: ref_cat_ids).pluck(:name_en, :id)
      ref_cat_en_names.sort.map { |s| { s[1].to_s => s[0] } }
    end
  end

  def referral_source_options(klass_name = 'Client')
    referral_sources = @user.admin? ? klass_name.constantize.referral_source_is : klass_name.constantize.where(user_id: @user.id).referral_source_is
    referral_sources.sort.map { |s| { s[1].to_s => s[0] } }
  end
end
