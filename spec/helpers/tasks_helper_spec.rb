describe TasksHelper, 'methods' do
  let!(:client){ create(:client) }
  let!(:domain){ create(:domain) }
  let!(:task){ create(:task, client: client, domain: domain) }
  let!(:other_task){ create(:task) }
  let!(:case_note){ create(:case_note, client: client) }
  let!(:cdg){ create(:case_note_domain_group, case_note: case_note, domain_group: domain.domain_group ) }

  context 'domains_tasks' do
    it 'show all tasks regarding to given current case_note and domains' do
      expect(domains_tasks(case_note, cdg)).to include(task)
    end

    it 'does not show irrelevant tasks' do
      expect(domains_tasks(case_note, cdg)).not_to include(other_task)
    end
  end
end
