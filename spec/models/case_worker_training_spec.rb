require 'rails_helper'

RSpec.describe CaseWorkerTraining, 'associations', type: :model do
  it { is_expected.to belong_to(:case_worker) }
  it { is_expected.to belong_to(:training) }
end
