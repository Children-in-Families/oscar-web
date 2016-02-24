class FamilySerializer < ActiveModel::Serializer
  attributes :name, :address, :caregiver_information

  def address
    "#{object.try(:house)}, #{object.try(:street)}, #{object.province.try(:name)}"
  end
end
