describe 'Abilities' do
  subject(:ability){ Ability.new(user) }

  context 'login as admin' do
    let!(:user){ create(:user, :admin) }

    it 'should be able to manage Agency' do
      should be_able_to(:manage, Agency.new)
    end

    it 'should be able to manage ReferralSource' do
      should be_able_to(:manage, ReferralSource.new)
    end

    it 'should be able to manage QuarterlyReport' do
      should be_able_to(:manage, QuarterlyReport.new)
    end

    it 'should be able to manage ProgramStream' do
      should be_able_to(:manage, ProgramStream.new)
    end

    it 'should be able to manage AbleScreeningQuestion' do
      should be_able_to(:manage, AbleScreeningQuestion.new)
    end

    it 'should be able to manage Assessment' do
      should be_able_to(:manage, Assessment.new)
    end

    it 'should be able to manage Attachment' do
      should be_able_to(:manage, Attachment.new)
    end

    it 'should be able to manage Case' do
      should be_able_to(:manage, Case.new)
    end

    it 'should be able to manage CaseNote' do
      should be_able_to(:manage, CaseNote.new)
    end

    it 'should be able to manage Client' do
      should be_able_to(:manage, Client.new)
    end

    it 'should be able to manage ProgressNote' do
      should be_able_to(:manage, ProgressNote.new)
    end

    it 'should be able to manage Task' do
      should be_able_to(:manage, Task.new)
    end

    it 'should be able to manage CustomFieldProperty' do
      should be_able_to(:manage, CustomFieldProperty.new)
    end

    it 'should be able to manage CustomField' do
      should be_able_to(:manage, CustomField.new)
    end

    it 'should be able to manage ClientEnrollment' do
      should be_able_to(:manage, ClientEnrollment.new)
    end

    it 'should be able to manage ClientEnrollmentTracking' do
      should be_able_to(:manage, ClientEnrollmentTracking.new)
    end

    it 'should be able to manage LeaveProgram' do
      should be_able_to(:manage, LeaveProgram.new)
    end
  end
end
