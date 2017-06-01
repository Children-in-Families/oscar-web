require 'spec_helper'

RSpec.describe CustomFieldSerializer, type: :serializer do
  let(:custom_field) { create(:custom_field) }
  let(:serializer) { CustomFieldSerializer.new(custom_field).to_json }

  it 'should be have attribute custom_field as root path' do
    expect(serializer).to have_json_size(1)
    expect(serializer).to have_json_type(Object).at_path('custom_field')
  end

  it 'should be have attribute id' do
    expect(serializer).to have_json_path('custom_field/id')
    expect(serializer).to have_json_type(Integer).at_path('custom_field/id')
  end

  it 'should be have attribute form_title' do
    expect(serializer).to have_json_path('custom_field/form_title')
    expect(serializer).to have_json_type(String).at_path('custom_field/form_title')
  end
end
