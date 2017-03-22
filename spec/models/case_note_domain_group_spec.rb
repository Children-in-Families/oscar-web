describe CaseNoteDomainGroup, 'associations' do
  it { is_expected.to belong_to(:case_note)}
  it { is_expected.to belong_to(:domain_group)}
  it { is_expected.to have_many(:tasks)}
end

describe CaseNoteDomainGroup, 'methods' do
  let!(:cdg)  { create(:case_note_domain_group) }
  let!(:completed_task) { create(:task, case_note_domain_group: cdg, completed: true) }
  let!(:incomplete_task) { create(:task, case_note_domain_group: cdg, completed: false) }
  context 'completed_tasks' do
    it 'should include only completed tasks' do
      expect(cdg.completed_tasks).to include(completed_task)
    end
    it 'should not include incomplete tasks' do
      expect(cdg.completed_tasks).not_to include(incomplete_task)
    end
  end
end

describe CaseNoteDomainGroup, 'scopes' do
  let!(:first_domain_group){ create(:domain_group, name: '1') }
  let!(:second_domain_group){ create(:domain_group, name: '2') }
  let!(:cdg){ create(:case_note_domain_group, domain_group: first_domain_group) }
  let!(:other_cdg){ create(:case_note_domain_group, domain_group: second_domain_group) }
  context 'in_order' do
    it 'should order by domain_group_id' do
      expect(CaseNoteDomainGroup.in_order).to eq([cdg, other_cdg])
    end
  end
end
