describe AdvancedSearches::QuantitativeCaseFields, 'Method' do
  before do
    allow_any_instance_of(Client).to receive(:generate_random_char).and_return("abcd")
  end
  let!(:user) { create(:user, :admin) }
  let!(:quantitative_type) { create(:quantitative_type) }
  let!(:quantitative_case) { create(:quantitative_case, quantitative_type: quantitative_type) }

  before do
    quantitative_cases_fields = AdvancedSearches::QuantitativeCaseFields.new(user)
    @quantitative_cases_fields = quantitative_cases_fields.render
    @fields = @quantitative_cases_fields.last
  end

  context 'render' do
    it 'return field not nil' do
      expect(@quantitative_cases_fields).not_to be_nil
    end

    it 'return all fields' do
      expect(@quantitative_cases_fields.size).to equal 1
    end

    it 'return field with id' do
      expect(@fields[:id]).to include "quantitative__#{quantitative_case.id}"
    end

    it 'return field with optGroup' do
      expect(@fields[:optgroup]).to include 'Custom Referral Data'
    end

    it 'return field with label' do
      expect(@fields[:label]).to include quantitative_type.name
    end
  end
end
