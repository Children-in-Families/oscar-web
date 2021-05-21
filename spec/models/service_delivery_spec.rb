RSpec.describe ServiceDelivery, type: :model do
  describe ServiceDelivery, 'associations' do
    it { is_expected.to have_many(:service_delivery_tasks).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:tasks).through(:service_delivery_tasks) }
  end

  describe ServiceDelivery, 'validations' do
    it { is_expected.to validate_presence_of(:name) }
  end

end
