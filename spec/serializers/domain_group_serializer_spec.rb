require 'spec_helper'

describe DomainGroupSerializer, type: :serializer do
  let(:domain_group) { create(:domain_group) }
  let!(:domains) { create_list(:domain, 2, domain_group: domain_group)}
  let(:serializer) { DomainGroupSerializer.new(domain_group).to_json }

  it 'should be have attribute domain_group as root path' do
    expect(serializer).to have_json_size(1)
    expect(serializer).to have_json_type(Object).at_path('domain_group')
  end

  it 'should be have attribute id' do
    expect(serializer).to have_json_path('domain_group/id')
    expect(serializer).to have_json_type(Integer).at_path('domain_group/id')
  end

  it 'should be have attribute name' do
    expect(serializer).to have_json_path('domain_group/name')
    expect(serializer).to have_json_type(String).at_path('domain_group/name')
  end

  it 'should be have attribute description' do
    expect(serializer).to have_json_path('domain_group/description')
    expect(serializer).to have_json_type(String).at_path('domain_group/description')
  end

  it 'should be have attribute domains' do
    expect(serializer).to have_json_path('domain_group/domains')
    expect(serializer).to have_json_type(Array).at_path('domain_group/domains')
  end
end