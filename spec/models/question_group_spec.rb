require 'rails_helper'

RSpec.describe QuestionGroup, type: :model do
  describe 'Association' do
    it { is_expected.to have_many(:able_screening_questions) }
  end
end
