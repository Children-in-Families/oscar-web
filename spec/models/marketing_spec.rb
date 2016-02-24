require 'rails_helper'

RSpec.describe Marketing, 'associations', type: :model do
  it { is_expected.to belong_to(:case_worker) }
end
