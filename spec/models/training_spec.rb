require 'rails_helper'

RSpec.describe Training, 'associations', type: :model do
  it { is_expected.to belong_to(:organization) }
  it { is_expected.to have_many(:case_worker_trainings) }
  it { is_expected.to have_many(:case_workers).through(:case_worker_trainings) }
end
