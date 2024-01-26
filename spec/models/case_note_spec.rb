describe CaseNote do
  before do
    allow_any_instance_of(Client).to receive(:generate_random_char).and_return("abcd")
  end
  describe CaseNote, 'associations' do
    it { is_expected.to belong_to(:client) }
    it { is_expected.to belong_to(:family) }
    it { is_expected.to belong_to(:assessment) }
    it { is_expected.to have_many(:case_note_domain_groups) }
    it { is_expected.to have_many(:domain_groups) }

    it { is_expected.to accept_nested_attributes_for(:case_note_domain_groups) }
  end

  describe CaseNote, 'validations' do
    it { is_expected.to validate_presence_of(:meeting_date) }
    it { is_expected.to validate_presence_of(:attendee) }
    it { is_expected.to validate_presence_of(:interaction_type) }
    it { is_expected.to validate_inclusion_of(:interaction_type).in_array(CaseNote::INTERACTION_TYPE)}
  end

  describe CaseNote, 'methods' do
    let!(:case_note){ create(:case_note) }

    context 'populate notes' do
      let!(:domain_group){ create(:domain_group) }
      before do
        case_note.populate_notes(nil, 'false')
      end

      xit { expect(case_note.case_note_domain_groups.size).to be > 0 }
      xit 'should build case note domain group with domain groups' do
        expect(case_note.case_note_domain_groups.map(&:domain_group)).to include(domain_group)
      end
    end

    context 'complete tasks' do
      let!(:domain_group){ create(:domain_group) }
      let!(:case_note_domain_group){ create(:case_note_domain_group, domain_group: domain_group, case_note: case_note) }
      let!(:task){ create(:task, completed: true, case_note_domain_group_id: case_note_domain_group.id) }
      let!(:other_task){ create(:task) }
      let!(:task_ids){ [task.id, other_task.id] }
      before do
        case_note.complete_tasks(
          {"0"=>
            {
              note: 'Test',
              domain_group_id: domain_group.id,
              task_ids: task_ids
            }
        })
        task.reload       
      end
      it{ expect(task.completed?).to be_truthy }
      it 'should have case note domain group association with task' do
        expect(case_note_domain_group.tasks).to include(task)
      end
    end

    context '#latest_record' do
      let!(:case_note){ create(:case_note, meeting_date: Date.yesterday) }
      let!(:case_note_1){ create(:case_note, meeting_date: Date.today) }
      subject(:latest_case_note) { CaseNote.latest_record }

      it 'should have first object as the latest case note by meeting date' do
        expect(latest_case_note).to eq(case_note_1)
      end

      it 'should not have first object as the latest case note by meeting date' do
        expect(latest_case_note).not_to eq(case_note)
      end
    end

    context 'family casenote' do
      let!(:family_case_note) { create(:case_note, belong_to_family: true) }
      context '#parent' do
        it 'should belong to a client' do
          expect(case_note.parent.class.name).to eq('Client')
        end

        it 'should not belong to the family' do
          expect(case_note.parent.class.name).not_to eq('Family')
        end

        it 'should belong to the family' do
          expect(family_case_note.parent.class.name).to eq('Family')
        end

        it 'should not belong to the client' do
          expect(family_case_note.parent.class.name).not_to eq('Client')
        end
      end
    end
  end

  describe CaseNote, 'scopes' do
    let!(:case_note){ create(:case_note, meeting_date: 1.month.ago) }
    let!(:latest_case_note){ create(:case_note, meeting_date: Date.yesterday) }

    context 'most recents' do
      it 'should have first object as the latest case note' do
        expect(CaseNote.recent_meeting_dates.first).to eq(latest_case_note)
      end
      it 'should not have first object not the latest case note' do
        expect(CaseNote.recent_meeting_dates.first).not_to eq(case_note)
      end
    end

    context 'no case note in' do
      it 'should not have one object as the case note' do
        expect(CaseNote.no_case_note_in(1.month.ago)).not_to include(latest_case_note)
      end
      it 'should have one object as the latest case note' do
        expect(CaseNote.no_case_note_in(1.month.ago)).to include(case_note)
      end
    end
  end

  describe CaseNote, 'callbacks' do
    before { Setting.first.update(enable_custom_assessment: true) }
    let!(:client){ create(:client) }
    let!(:assessment){ create(:assessment, created_at: Time.now - 6.month - 1.day, client: client) }
    let!(:custom_assessment_1){ create(:assessment, :custom, created_at: Time.now - 6.month - 1.day, client: client) }
    let!(:latest_assessment){ create(:assessment, client: client) }
    let!(:custom_latest_assessment_1){ create(:assessment, :custom, client: client) }
    let!(:case_note){ create(:case_note, client: client) }
    let!(:custom_case_note_1){ create(:case_note, :custom, client: client) }
    let!(:other_client){ create(:client) }
    let!(:other_assessment){ create(:assessment, client: other_client) }
    let!(:other_custom_assessment_1){ create(:assessment, :custom, client: other_client) }

    context 'before_create' do
      context '#set_assessment' do
        context 'default case note' do
          it 'should set assessment to latest assessment' do
            expect(case_note.assessment).to eq(latest_assessment)
          end
          it 'should not set assessment to not latest assessment' do
            expect(case_note.assessment).not_to eq(assessment)
          end
          it 'should not set assessment to latest assessment of other client' do
            expect(case_note.assessment).not_to eq(other_assessment)
          end
        end

        context 'custom case note' do
          it 'should set assessment to custom latest assessment' do
            expect(custom_case_note_1.assessment).to eq(custom_latest_assessment_1)
          end
          it 'should not set assessment to not custom latest assessment' do
            expect(custom_case_note_1.assessment).not_to eq(custom_assessment_1)
          end
          it 'should not set assessment to custom latest assessment of other client' do
            expect(custom_case_note_1.assessment).not_to eq(other_custom_assessment_1)
          end
        end
      end
    end
  end
end
