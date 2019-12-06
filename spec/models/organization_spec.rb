describe Organization do
  describe 'Validations' do
    it { is_expected.to validate_presence_of(:short_name) }
    it { is_expected.to validate_presence_of(:full_name) }
    it { is_expected.to validate_uniqueness_of(:short_name).case_insensitive }
  end

  describe 'Associations' do
    it { is_expected.to have_many(:employees) }
  end

  describe 'Scopes' do
    let!(:cambodian_org) { create(:organization, short_name: 'kho', full_name: 'Cambodian Organization', country: 'cambodia') }
    let!(:malaysian_org) { create(:organization, short_name: 'myo', full_name: 'Malaysian Organization', country: 'malaysia') }

    describe '.cambodian scope' do
      subject { Organization.cambodian }

      it 'returns alls orgnanizations located in Cambodia' do
        expect(subject).to include(cambodian_org)
        expect(subject).not_to include(malaysian_org)
      end
    end

    xdescribe '.without_demo scope' do
      let!(:demo_org) { create(:organization, full_name: 'Demo')}
      subject { Organization.without_demo }

      it 'returns all orgnaizations except the demo orgnaization' do
        expect(subject).to include(cambodian_org, malaysian_org)
        expect(subject).not_to include(demo_org)
      end
    end

    xdescribe '.without_shared scope' do
      let!(:shared_org) { create(:organization, short_name: 'shared')}
      subject { Organization.without_shared }

      it 'returns all orgnaizations except the shared orgnaization' do
        expect(subject).to include(cambodian_org, malaysian_org)
        expect(subject).not_to include(shared_org)
      end
    end

    describe 'when cwd organization is created' do
      let!(:cwd_org) { create(:organization, short_name: 'cwd', full_name: 'cwd', country: 'india') }

      describe '.without_cwd scope' do
        subject { Organization.without_cwd }

        it 'returns all orgnaizations except the cwd orgnaization' do
          expect(subject).to include(cambodian_org, malaysian_org)
          expect(subject).not_to include(cwd_org)
        end
      end

      xdescribe 'when demo organization is created' do
        let!(:demo_org) { create(:organization, short_name: 'demo', full_name: 'cwd', country: 'india') }

        describe '.oscar scope' do
          subject { Organization.oscar }

          it 'should return organizations that are available_for_referral' do
            expect(subject.map{|org| org.available_for_referral?}.uniq.first).to be_truthy
          end

          it 'returns all live instances of oscar organizations' do
            expect(subject).to include(cambodian_org, malaysian_org)
            expect(subject).not_to include(cwd_org, demo_org)
          end
        end

        describe '.visible scope' do
          subject { Organization.visible }

          it 'returns all live instances of oscar organizations plus the demo instance' do
            expect(subject).to include(cambodian_org, malaysian_org, demo_org)
            expect(subject).not_to include(cwd_org)
          end
        end

        xdescribe '.skip_dup_checking_orgs' do
          subject { Organization.skip_dup_checking_orgs }

          it 'returns the demo org' do
            expect(subject).to include(demo_org)
          end
        end
      end
    end
  end
end
