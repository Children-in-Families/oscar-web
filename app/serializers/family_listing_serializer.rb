class FamilyListingSerializer < ActiveModel::Serializer
  attributes :id, :name, :name_en, :display_name, :code, :family_type, :status,
             :slug, :initial_referral_date

  has_many :family_members
end
