class FamilyMember < ActiveRecord::Base
  extend Enumerize
  belongs_to :family
  belongs_to :client

  has_paper_trail

  EN_RELATIONS = ['Father', 'Mother', 'Son', 'Daughter', 'Step Mother', 'Step Father', 'Step Son', 'Step Daughter', 'Foster Child', 'Brother', 'Sister', 'Uncle', 'Aunt', 'Grandmother', 'Grandfather', 'Grandson', 'Granddaughter', 'Relative', 'Neighbor', 'Friend', 'Other'].freeze
  KM_RELATIONS = ['ឪពុក', 'ម្ដាយ', 'កូនប្រុស', 'កូនស្រី', 'ម្ដាយចុង', 'ឪពុកចុង', 'កូនប្រុសចុង', 'កូនស្រីចុង', 'កូនចិញ្ចឹម', 'បងប្រុស/ប្អូនប្រុស', 'បងស្រី/ប្អូនស្រី', 'ពូ/អ៊ុំប្រុស', 'មីង/អ៊ុំស្រី', 'ជីដូន', 'ជីតា', 'ចៅប្រុស', 'ចៅស្រី', 'សាច់ញាតិ', 'អ្នកជិតខាង', 'មិត្តភក្តិ', 'ផ្សេងៗទៀត'].freeze
  MY_RELATIONS = ['ဖခင်', 'မိခင်', 'သား', 'သမီး', 'မိထွေး', 'ပထွေး', 'မယားပါသား/လင်ပါသား', 'မယားပါသမီး/လင်ပါသမီး', 'မွေးစားကလေး', 'မောင်နှမ/ညီအစ်ကို', 'ညီအစ်မ/မောင်နှမ', 'ဦးလေး', 'အဒေါ်', 'အဖွား', 'အဖိုး', 'မြေးប្រុស', 'မြေးမ', 'ဆွေမျိုး', 'အိမ်နီးနားချင်း', 'သူငယ်ချင်း', 'အခြား'].freeze

  enumerize :gender, in: ['female', 'male', 'lgbt', 'unknown', 'prefer_not_to_say', 'other'], scope: true, predicates: { prefix: true }

  after_commit :save_aggregation_data, on: [:create, :update]
  after_commit :save_client_data, if: :persisted?
  after_destroy :remove_family_from_client

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

  def remove_family_from_client
    Client.find(client_id_was).update_columns(current_family_id: nil)
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error e
  end
end
