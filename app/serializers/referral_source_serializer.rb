class ReferralSourceSerializer < ActiveModel::Serializer
  attributes :id, :name, :name_en, :description, :children

  def children
    ReferralSource.where(ancestry: object.id)
  end
end
