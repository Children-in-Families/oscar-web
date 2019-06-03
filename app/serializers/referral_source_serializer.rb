class ReferralSourceSerializer < ActiveModel::Serializer
  attributes :id, :name, :name_en, :description, :childrens

  def childrens
    ReferralSource.where(ancestry: object.id)
  end
end
