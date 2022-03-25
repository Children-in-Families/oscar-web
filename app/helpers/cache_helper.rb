module CacheHelper
  def user_cache_id
    [Apartment::Tenant.current, current_user.class.name, current_user.id]
  end
end