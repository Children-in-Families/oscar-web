module CacheHelper
  def user_cache_id
    [Apartment::Tenant.current, current_user.class.name, current_user.id]
  end

  def field_settings_cache_key
    [Apartment::Tenant.current, 'field_settings']
  end

  def setting_cache_key
    [Apartment::Tenant.current, 'current_setting']
  end

  def custom_fields_cache
    [Apartment::Tenant.current, 'custom_fields']
  end
end
