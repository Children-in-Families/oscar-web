describe AssessmentPolicy do
  let(:client_1){ create(:client, :accepted) }
  subject { AssessmentPolicy.new(user, assessment) }

  shared_examples 'create' do
    it { should authorize(:new) }
    it { should authorize(:create) }
  end

  shared_examples 'show' do
    it { should authorize(:index) }
    it { should authorize(:show) }
  end

  shared_examples 'update' do
    it { should authorize(:edit) }
    it { should authorize(:update) }
  end

  shared_examples 'unauthorized_create' do
    it { should_not authorize(:new) }
    it { should_not authorize(:create) }
  end

  shared_examples 'unauthorized_update' do
    it { should_not authorize(:edit) }
    it { should_not authorize(:update) }
  end

  shared_examples 'unauthorized_show' do
    it { should_not authorize(:index) }
    it { should_not authorize(:show) }
  end

  context 'CSI is enabled' do
    context 'within a week' do
      let(:assessment){ create(:assessment) }

      context 'for a strategic overviewer' do
        let(:user){ create(:user, :strategic_overviewer) }

        it_behaves_like 'show'

        it_behaves_like 'unauthorized_create' do
          let(:assessment){ build(:assessment) }
        end

        it_behaves_like 'unauthorized_update'
      end

      context 'for a case worker' do
        let(:user){ create(:user, client_ids: [client_1.id]) }
        let!(:client_1){ create(:client, date_of_birth: 5.years.ago) }
        let!(:assessment_1){ create(:assessment, client: client_1) }
        before { client_1.update(date_of_birth: 20.years.ago) }

        it_behaves_like 'create' do
          # client age matters
          let(:assessment){ build(:assessment) }
        end

        it_behaves_like 'unauthorized_create' do
          # client age matters
          let(:assessment){ build(:assessment, client: client_1) }
        end

        it_behaves_like 'show'

        it_behaves_like 'update' do
          # regardless the client age
          let(:assessment){ assessment_1 }
        end
      end

      context 'for a manager' do
        let(:user){ create(:user, :manager, client_ids: [client_1.id]) }

        it_behaves_like 'create' do
          let(:assessment){ build(:assessment) }
        end

        it_behaves_like 'show'
        it_behaves_like 'update'
      end

      context 'for an admin' do
        let(:user){ create(:user, :admin) }

        it_behaves_like 'create' do
          let(:assessment){ build(:assessment) }
        end

        it_behaves_like 'show'
        it_behaves_like 'update'
      end
    end

    context 'longer than a week' do
      let(:assessment){ create(:assessment, created_at: 1.week.ago) }

      context 'for a strategic overviewer' do
        let(:user){ create(:user, :strategic_overviewer) }

        it_behaves_like 'unauthorized_update'
      end

      context 'for a case worker' do
        let(:user){ create(:user, client_ids: [client_1.id]) }

        it_behaves_like 'unauthorized_update'
      end

      context 'for a manager' do
        let(:user){ create(:user, :manager, client_ids: [client_1.id]) }

        it_behaves_like 'unauthorized_update'
      end

      context 'for an admin' do
        let(:user){ create(:user, :admin) }

        it_behaves_like 'update'
      end
    end
  end

  context 'CSI is disabled' do
    let!(:assessment){ create(:assessment) }

    context 'for a strategic overviewer' do
      let(:user){ create(:user, :strategic_overviewer) }
      before { Setting.first.update(enable_default_assessment: false, enable_custom_assessment: false) }

      it_behaves_like 'unauthorized_show'

      it_behaves_like 'unauthorized_create' do
        let!(:assessment){ build(:assessment) }
      end

      it_behaves_like 'unauthorized_update'
    end

    context 'for a case worker' do
      let(:user){ create(:user) }
      before { Setting.first.update(enable_default_assessment: false, enable_custom_assessment: false) }

      it_behaves_like 'unauthorized_show'

      it_behaves_like 'unauthorized_create' do
        let!(:assessment){ build(:assessment) }
      end

      it_behaves_like 'unauthorized_update'
    end

    context 'for a manager' do
      let(:user){ create(:user, :manager) }
      before { Setting.first.update(enable_default_assessment: false, enable_custom_assessment: false) }

      it_behaves_like 'unauthorized_show'

      it_behaves_like 'unauthorized_create' do
        let!(:assessment){ build(:assessment) }
      end

      it_behaves_like 'unauthorized_update'
    end

    context 'for an admin' do
      let(:user){ create(:user, :admin) }
      before { Setting.first.update(enable_default_assessment: false, enable_custom_assessment: false) }

      it_behaves_like 'unauthorized_show'

      it_behaves_like 'unauthorized_create' do
        let!(:assessment){ build(:assessment) }
      end

      it_behaves_like 'unauthorized_update'
    end
  end
end
