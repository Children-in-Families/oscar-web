module Brc::Family
  extend ActiveSupport::Concern

  included do
    after_commit :save_aggregation_data, if: :persisted?
  end

  def save_aggregation_data
    update_columns(
      significant_family_member_count: family_members.count,
      male_adult_count: family_members.where('gender = ? AND date_of_birth <= ?', :male, 18.years.ago).count,
      female_adult_count: family_members.where('gender = ? AND date_of_birth <= ?', :female, 18.years.ago).count,
      male_children_count: family_members.where('gender = ? AND date_of_birth > ?', :male, 18.years.ago).count,
      female_children_count: family_members.where('gender = ? AND date_of_birth > ?', :female, 18.years.ago).count
    )
  end

  private

  def brc?
    Organization.current&.short_name == 'brc'
  end
end
