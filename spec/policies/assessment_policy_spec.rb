describe AssessmentPolicy do
  subject { AssessmentPolicy.new(user, assessment) }

  shared_examples 'authorized' do
    it { should authorize(:index) }
    it { should authorize(:show) }
    it { should authorize(:new) }
    it { should authorize(:create) }
    it { should authorize(:edit) }
    it { should authorize(:update) }
  end

  shared_examples 'unauthorized' do
    it { should_not authorize(:index) }
    it { should_not authorize(:show) }
    it { should_not authorize(:new) }
    it { should_not authorize(:create) }
    it { should_not authorize(:edit) }
    it { should_not authorize(:update) }
  end

  context 'CSI is enabled' do
    context 'within a week' do
      let(:assessment){ create(:assessment) }

      context 'for a strategic overviewer' do
        let(:user){ create(:user, :strategic_overviewer) }

        it { should authorize(:index) }
        it { should authorize(:show) }
        it { should_not authorize(:new) }
        it { should_not authorize(:create) }
        it { should_not authorize(:edit) }
        it { should_not authorize(:update) }
      end

      context 'for a case worker' do
        let(:user){ create(:user) }

        it_behaves_like 'authorized'
      end

      context 'for a manager' do
        let(:user){ create(:user, :manager) }

        it_behaves_like 'authorized'
      end

      context 'for an admin' do
        let(:user){ create(:user, :admin) }

        it_behaves_like 'authorized'
      end
    end

    context 'longer than a week' do
      let(:assessment){ create(:assessment, created_at: 1.week.ago) }

      context 'for a strategic overviewer' do
        let(:user){ create(:user, :strategic_overviewer) }

        it { should_not authorize(:edit) }
        it { should_not authorize(:update) }
      end

      context 'for a case worker' do
        let(:user){ create(:user) }

        it { should_not authorize(:edit) }
        it { should_not authorize(:update) }
      end

      context 'for a manager' do
        let(:user){ create(:user, :manager) }

        it { should_not authorize(:edit) }
        it { should_not authorize(:update) }
      end

      context 'for an admin' do
        let(:user){ create(:user, :admin) }

        it { should authorize(:edit) }
        it { should authorize(:update) }
      end
    end
  end

  context 'CSI is disabled' do
    let!(:assessment){ create(:assessment) }

    context 'for a strategic overviewer' do
      let(:user){ create(:user, :strategic_overviewer) }
      before { Setting.first.update(disable_assessment: true) }

      it_behaves_like 'unauthorized'
    end

    context 'for a case worker' do
      let(:user){ create(:user) }
      before { Setting.first.update(disable_assessment: true) }

      it_behaves_like 'unauthorized'
    end

    context 'for a manager' do
      let(:user){ create(:user, :manager) }
      before { Setting.first.update(disable_assessment: true) }

      it_behaves_like 'unauthorized'
    end

    context 'for an admin' do
      let(:user){ create(:user, :admin) }
      before { Setting.first.update(disable_assessment: true) }

      it_behaves_like 'unauthorized'
    end
  end
end
