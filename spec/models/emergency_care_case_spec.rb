require 'rails_helper'

RSpec.describe EmergencyCareCase, 'associations', type: :model do
  it { is_expected.to belong_to(:client) }
  it { is_expected.to belong_to(:case_worker) }
  it { is_expected.to belong_to(:partner) }
end
