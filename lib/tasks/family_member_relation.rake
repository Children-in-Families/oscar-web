namespace :family_member_relation do
  desc "Migrate family member relations Khmer to English"
  task migrate: :environment do
    Organization.without_shared.pluck(:short_name).each do |short_name|
      Apartment::Tenant.switch short_name
      relation_hash = FamilyMember::KM_RELATIONS.zip(FamilyMember::EN_RELATIONS).to_h
      family_members = FamilyMember.where.not(relation: "")
      family_members.each do |family_member|
        relation = relation_hash[family_member.relation]
        family_member.update_column(:relation, relation) if relation
      end
    end
  end

end
