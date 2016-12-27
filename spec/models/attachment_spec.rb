describe Attachment, 'associations' do
  it { is_expected.to belong_to(:progress_note) }
  it { is_expected.to belong_to(:able_screening_question) }
end
