require 'spec_helper'

describe DomainGroupSerializer, type: :serializer do
  let(:quantitative_type) { create(:quantitative_type) }
  let!(:quantitative_case) { create(:quantitative_case, quantitative_type: quantitative_type)}
  let(:serializer) { QuantitativeTypeSerializer.new(quantitative_type).to_json }

  it 'should be have attribute quantitative_type as root path' do
    expect(serializer).to have_json_size(1)
    expect(serializer).to have_json_type(Object).at_path('quantitative_type')
  end

  it 'should be have attribute id' do
    expect(serializer).to have_json_path('quantitative_type/id')
    expect(serializer).to have_json_type(Integer).at_path('quantitative_type/id')
  end

  it 'should be have attribute name' do
    expect(serializer).to have_json_path('quantitative_type/name')
    expect(serializer).to have_json_type(String).at_path('quantitative_type/name')
  end

  it 'should be have attribute description' do
    expect(serializer).to have_json_path('quantitative_type/description')
    expect(serializer).to have_json_type(String).at_path('quantitative_type/description')
  end

  it 'should be have attribute quantitative_cases' do
    expect(serializer).to have_json_path('quantitative_type/quantitative_cases')
    expect(serializer).to have_json_type(Array).at_path('quantitative_type/quantitative_cases')
  end
end