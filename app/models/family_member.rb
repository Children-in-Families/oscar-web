class FamilyMember < ActiveRecord::Base
  extend Enumerize
  belongs_to :family

  has_paper_trail

  EN_RELATIONS = [ 'Father', 'Mother', 'Brother', 'Sister', 'Uncle', 'Aunt', 'Grandfather', 'Grandmother', 'Relative', 'Neighbor', 'Friend' ]
  KM_RELATIONS = [ 'ឪពុក', 'ម្ដាយ', 'បងប្រុស', 'បងស្រី', 'ពូ', 'មីង', 'អ៊ុំ', 'ជីដូន', 'ជីតា', 'សាច់ញាតិ', 'អ្នកជិតខាង', 'មិត្តភ័ក្ត' ]
  MY_RELATIONS = [ 'ဖခင်', 'မိခင်', 'အစ်ကို', 'အစ်မ', 'ဘကြီး', 'အဒေါ်', 'အဘိုး', 'အဖွါး', 'ဆွေမျိုး', 'အိမ်နီးချင်း', 'မိတျဆှေ']

  enumerize :gender, in: ['female', 'male', 'lgbt', 'unknown', 'prefer_not_to_say', 'other'], scope: true, predicates: { prefix: true }

  after_commit :save_aggregation_data, on: [:create, :update], if: :brc?

  private

  def save_aggregation_data
    family&.save_aggregation_data
  end

  def brc?
    Organization.current&.short_name == 'brc'
  end
end
