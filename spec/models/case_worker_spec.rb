require 'rails_helper'

RSpec.describe CaseWorker, 'associations', type: :model do
  it { is_expected.to belong_to(:province) }
  it { is_expected.to have_many(:clients) }
  it { is_expected.to have_many(:case_worker_trainings) }
  it { is_expected.to have_many(:training).through(:case_worker_trainings) }
end
