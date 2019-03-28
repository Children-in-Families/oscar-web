describe AdvancedSearches::CustomFields, 'Method' do
  let(:custom_field)  { create(:custom_field) }

  before do
    @custom_fields = AdvancedSearches::CustomFields.new([custom_field.id]).render
    @fields = @custom_fields.first
  end

  context 'render' do
    it 'return field not nil' do
      expect(@custom_fields).not_to be_nil
    end

    it 'return all fields' do
      expect(@custom_fields.size).to equal 1
    end

    it 'return field with id' do
      expect(@fields[:id]).to include "formbuilder__#{custom_field.form_title}__Name"
    end

    it 'return field with optGroup' do
      expect(@fields[:optgroup]).to include "#{custom_field.form_title} | Custom Form"
    end

    it 'return field with label' do
      expect(@fields[:label]).to include 'Name'
    end
  end
end
