require 'rails_helper'

describe Goal, 'associations' do
  it { is_expected.to belong_to(:domain).counter_cache(true) }
  it { is_expected.to belong_to(:assessment_domain) }
  it { is_expected.to belong_to(:client) }
  it { is_expected.to belong_to(:care_plan) }
  it { is_expected.to belong_to(:family) }

  it { is_expected.to have_many(:tasks).dependent(:destroy)}
end

describe Goal, 'validations' do
  it { is_expected.to validate_presence_of(:description) }
end
