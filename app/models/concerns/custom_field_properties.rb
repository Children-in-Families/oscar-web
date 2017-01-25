module CustomFieldProperties

  def properties_objs
    if self.properties.present?
      JSON.parse(self.properties)
    else
      {}
    end
  end
end
