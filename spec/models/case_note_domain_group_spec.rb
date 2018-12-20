describe CaseNoteDomainGroup, 'associations' do
  it { is_expected.to belong_to(:case_note)}
  it { is_expected.to belong_to(:domain_group)}
  it { is_expected.to have_many(:tasks)}
end

describe CaseNoteDomainGroup, 'methods' do
  let!(:cdg)  { create(:case_note_domain_group) }
  let!(:completed_task) { create(:task, case_note_domain_group: cdg, completed: true) }
  let!(:incomplete_task) { create(:task, case_note_domain_group: cdg, completed: false) }
  let!(:client_1){ create(:client, :accepted) }
  let!(:domain_group_1){ create(:domain_group) }
  let!(:domain_group_2){ create(:domain_group) }
  let!(:domain_1){ create(:domain, domain_group: domain_group_1, identity: 'Food') }
  let!(:custom_domain_1){ create(:domain, :custom, domain_group: domain_group_1) }
  let!(:custom_domain_2){ create(:domain, :custom, domain_group: domain_group_2, identity: 'Clothes') }
  let!(:custom_domain_3){ create(:domain, :custom, domain_group: domain_group_2, identity: 'Shelter') }
  let!(:assessment_1){ create(:assessment, client: client_1) }
  let!(:assessment_domain_1){ create(:assessment_domain, assessment: assessment_1, domain: domain_1) }
  let!(:case_note_1){ create(:case_note, client: client_1) }
  let!(:custom_case_note_1){ create(:case_note, :custom) }
  let!(:case_note_domain_group_1){ create(:case_note_domain_group, case_note: case_note_1, domain_group: domain_group_1) }
  let!(:case_note_domain_group_2){ create(:case_note_domain_group, case_note: custom_case_note_1, domain_group: domain_group_2) }

  context '#completed_tasks' do
    it 'should include only completed tasks' do
      expect(cdg.completed_tasks).to include(completed_task)
    end
    it 'should not include incomplete tasks' do
      expect(cdg.completed_tasks).not_to include(incomplete_task)
    end
  end

  context '#any_assessment_domains?(case_note)' do
    it 'by assessment' do
      expect(case_note_domain_group_1.any_assessment_domains?(case_note_1)).to be_truthy
      expect(case_note_domain_group_2.any_assessment_domains?(case_note_domain_group_2.case_note)).to be_falsey
    end
  end

  context '#domains(case_note)' do
    it 'get domains by type of case note whether custom or default' do
      expect(case_note_domain_group_1.domains(case_note_1)).to eq([domain_1])
      expect(case_note_domain_group_1.domains(case_note_1)).not_to include(custom_domain_1)
    end
  end

  context '#domain_identities' do
    it 'scopes by type of case note whether custom or default' do
      expect(case_note_domain_group_1.domain_identities).to eq('Food')
      expect(case_note_domain_group_2.domain_identities).to eq('Clothes, Shelter')
    end
  end
end

describe CaseNoteDomainGroup, 'scopes' do
  let!(:first_domain_group){ create(:domain_group, name: '1') }
  let!(:second_domain_group){ create(:domain_group, name: '2') }
  let!(:cdg){ create(:case_note_domain_group, domain_group: first_domain_group) }
  let!(:other_cdg){ create(:case_note_domain_group, domain_group: second_domain_group) }
  context 'default_scope' do
    it 'should order by domain_group_id' do
      expect(CaseNoteDomainGroup.all).to eq([cdg, other_cdg])
    end
  end
end
