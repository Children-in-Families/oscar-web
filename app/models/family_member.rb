class FamilyMember < ActiveRecord::Base
  extend Enumerize
  belongs_to :family
  belongs_to :client

  has_paper_trail

  EN_RELATIONS = ['Father', 'Mother', 'Son', 'Daughter', 'Foster Child', 'Brother', 'Sister', 'Uncle', 'Aunt', 'Grandmother', 'Grandfather', 'Grandson', 'Granddaughter', 'Relative', 'Neighbor', 'Friend']
  KM_RELATIONS = ['ឪពុក', 'ម្ដាយ', 'កូនប្រុស', 'កូនស្រី', 'កូនចិញ្ចឹម', 'បងប្រុស', 'បងស្រី', 'ពូ', 'មីង', 'ជីដូន', 'ជីតា', 'ចៅប្រុស', 'ចៅស្រី', 'សាច់ញាតិ', 'អ្នកជិតខាង', 'មិត្តភ័ក្ត']
  MY_RELATIONS = ['ဖခင်', 'မိခင်', 'သား', 'သမီး', 'မွေးစားကလေး', 'အစ်ကို', 'အစ်မ', 'ဘကြီး', 'အဒေါ်', 'အဖွါး', 'အဘိုး', 'မြေး', 'မြေး', 'ဆွေမျိုး', 'အိမ်နီးချင်း', 'မိတျဆှေ']

  enumerize :gender, in: ['female', 'male', 'lgbt', 'unknown', 'prefer_not_to_say', 'other'], scope: true, predicates: { prefix: true }

  after_commit :save_aggregation_data, on: [:create, :update]
  after_commit :save_client_data, if: :persisted?

  validates :client_id, uniqueness: { scope: :family_id }, if: :client_id?

  def self.update_client_relevant_data(family_member_id, org_name)
    Organization.switch_to(org_name)
    find(family_member_id)&.save_client_data if exists?(family_member_id)
  end

  def is_client
    client_id?
  end

  def save_client_data
    if client.present?
      update_columns(
        adult_name: (client.name.presence || client.display_name),
        gender: client.gender,
        date_of_birth: client.date_of_birth
      )
    end
  end

  def serializable_hash(options = nil)
    return super if client.nil?

    super.merge(
      profile: client.profile
    )
  end

  private

  def save_aggregation_data
    family&.save_aggregation_data
  end
end
