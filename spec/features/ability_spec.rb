describe 'Abilities' do
  subject(:ability){ Ability.new(user) }

  context 'admin permissions' do
    let!(:user){ create(:user, :admin) }

    it 'can manage Agency' do
      should be_able_to(:manage, Agency.new)
    end

    it 'can manage ReferralSource' do
      should be_able_to(:manage, ReferralSource.new)
    end

    it 'can manage QuarterlyReport' do
      should be_able_to(:manage, QuarterlyReport.new)
    end

    it 'can manage ProgramStream' do
      should be_able_to(:manage, ProgramStream.new)
    end

    it 'can manage AbleScreeningQuestion' do
      should be_able_to(:manage, AbleScreeningQuestion.new)
    end

    it 'can manage Assessment' do
      should be_able_to(:manage, Assessment.new)
    end

    it 'can manage Attachment' do
      should be_able_to(:manage, Attachment.new)
    end

    it 'can manage Case' do
      should be_able_to(:manage, Case.new)
    end

    it 'can manage CaseNote' do
      should be_able_to(:manage, CaseNote.new)
    end

    it 'can manage Client' do
      should be_able_to(:manage, Client.new)
    end

    it 'can manage ProgressNote' do
      should be_able_to(:manage, ProgressNote.new)
    end

    it 'can manage Task' do
      should be_able_to(:manage, Task.new)
    end

    it 'can manage CustomFieldProperty' do
      should be_able_to(:manage, CustomFieldProperty.new)
    end

    it 'can manage CustomField' do
      should be_able_to(:manage, CustomField.new)
    end

    it 'can manage ClientEnrollment' do
      should be_able_to(:manage, ClientEnrollment.new)
    end

    it 'can manage ClientEnrollmentTracking' do
      should be_able_to(:manage, ClientEnrollmentTracking.new)
    end

    it 'can manage LeaveProgram' do
      should be_able_to(:manage, LeaveProgram.new)
    end
  end
end
