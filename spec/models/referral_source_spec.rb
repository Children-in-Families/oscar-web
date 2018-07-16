describe ReferralSource, 'validation' do
  it { is_expected.to have_many(:clients).dependent(:restrict_with_error) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name).case_insensitive }

  describe ReferralSource, 'callbacks' do
    context 'restrict user from deleting or making changes' do
      let!(:referral_source){ create(:referral_source, name: 'អង្គការមិនមែនរដ្ឋាភិបាល') }

      it 'should not be deleted' do
        referral_source.destroy
        expect(referral_source.errors.full_messages).to include('Referral Source cannot be deleted')
      end

      it 'should not be updated' do
        referral_source.update(name: 'ABC')
        expect(referral_source.errors.full_messages).to include('Referral Source cannot be updated')
      end
    end
  end
end
