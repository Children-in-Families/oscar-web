require 'rails_helper'

RSpec.describe Partner, 'associations', type: :model do
  it { is_expected.to belong_to(:village) }
end
