RSpec.describe ServiceDeliveryTask, type: :model do
  describe ServiceDeliveryTask, 'associations' do
    it { is_expected.to belong_to(:task) }
    it { is_expected.to belong_to(:service_delivery) }
  end
end
