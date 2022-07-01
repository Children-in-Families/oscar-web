class CustomFieldPropertyUpdateWorker
  include Sidekiq::Worker
  include UpdateFieldLabelsFormBuilder

  def perform(short_name, new_fields, old_fields, object_ids)
    Apartment::Tenant.switch short_name
    objects = CustomFieldProperty.where(id: object_ids)
    labels_update(new_fields, old_fields, objects)
  end
end
