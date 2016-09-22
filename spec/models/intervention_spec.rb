describe Intervention, 'validations' do
  it { is_expected.to validate_presence_of(:action)}
  it { is_expected.to validate_uniqueness_of(:action)}
  it { is_expected.to have_and_belong_to_many(:progress_notes) }
end

describe Intervention, 'methods' do
  let!(:intervention){ create(:intervention) }
  let!(:used_intervention){ create(:intervention) }
  let!(:progress_note){ create(:progress_note, intervention_ids: used_intervention.id) }
  context 'has_no_any_progress_notes?' do
    it{ expect(intervention.has_no_any_progress_notes?).to be_truthy }
    it{ expect(used_intervention.has_no_any_progress_notes?).to be_falsey }
  end
end
