class CommunityMember < ActiveRecord::Base
  extend Enumerize

  belongs_to :family
  belongs_to :community

  has_paper_trail

  EN_RELATIONS = [ 'Father', 'Mother', 'Brother', 'Sister', 'Uncle', 'Aunt', 'Grandfather', 'Grandmother', 'Relative', 'Neighbor', 'Friend' ]
  KM_RELATIONS = [ 'ឪពុក', 'ម្ដាយ', 'បងប្រុស', 'បងស្រី', 'ពូ', 'មីង', 'អ៊ុំ', 'ជីដូន', 'ជីតា', 'សាច់ញាតិ', 'អ្នកជិតខាង', 'មិត្តភ័ក្ត' ]
  MY_RELATIONS = [ 'ဖခင်', 'မိခင်', 'အစ်ကို', 'အစ်မ', 'ဘကြီး', 'အဒေါ်', 'အဘိုး', 'အဖွါး', 'ဆွေမျိုး', 'အိမ်နီးချင်း', 'မိတျဆှေ']

  enumerize :gender, in: ['female', 'male', 'lgbt', 'unknown', 'prefer_not_to_say', 'other'], scope: true, predicates: { prefix: true }

  after_commit :save_family_data

  def self.update_family_relevant_data(family_member_id)
    find(family_member_id).save_family_data
  end

  def is_family
    family_id?
  end

  def save_family_data
    if family.present?
      update_columns(
        name: family.display_name,
        adule_male_count: family.male_adult_count,
        adule_female_count: family.female_adult_count,
        kid_male_count: family.male_children_count,
        kid_female_count: family.female_children_count
      )
    end
  end
end
