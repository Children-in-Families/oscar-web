module CustomFieldProperties

  def properties_objs
    JSON.parse(self.properties) if self.properties.present?
  end
end
