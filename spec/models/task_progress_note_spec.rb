require 'rails_helper'

RSpec.describe TaskProgressNote, type: :model do
  describe TaskProgressNote, 'associations' do
    it { is_expected.to belong_to(:task)}
  end

  describe TaskProgressNote, 'validations' do
    it { is_expected.to validate_presence_of(:progress_note) }
  end
end
