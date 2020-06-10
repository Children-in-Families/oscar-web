describe QuarterlyReport do
  before do
    allow_any_instance_of(Client).to receive(:generate_random_char).and_return("abcd")
  end
  describe QuarterlyReport, 'associations' do
    it { is_expected.to belong_to(:case) }
    it { is_expected.to belong_to(:staff_information)}
  end

  describe QuarterlyReport, 'methods' do
    let!(:kc_case){ create(:case, case_type: 'KC') }
    let!(:fc_case){ create(:case, case_type: 'FC') }
    let!(:kc_quarterly_report){ create(:quarterly_report, case: kc_case) }
    let!(:fc_quarterly_report){ create(:quarterly_report, case: fc_case) }
    context 'kinship?' do
      it { expect(kc_quarterly_report.kinship?).to be_truthy }
      it { expect(fc_quarterly_report.kinship?).to be_falsey }
    end

    context 'foster?' do
      it { expect(fc_quarterly_report.foster?).to be_truthy }
      it { expect(kc_quarterly_report.foster?).to be_falsey }
    end
  end
end