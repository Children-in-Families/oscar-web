module Brc::Family
  extend ActiveSupport::Concern

  def male_adult_count
    brc? ? family_members.where('gender = ? AND date_of_birth <= ?', :male, 18.years.ago).count : super
  end

  def female_adult_count
    brc? ? family_members.where('gender = ? AND date_of_birth <= ?', :female, 18.years.ago).count : super
  end

  def male_children_count
    brc? ? family_members.where('gender = ? AND date_of_birth > ?', :male, 18.years.ago).count : super
  end

  def female_children_count
    brc? ? family_members.where('gender = ? AND date_of_birth > ?', :female, 18.years.ago).count : super
  end

  def brc?
    Organization.current&.short_name == 'brc'
  end
end
