require 'spec_helper'

describe ProvinceSerializer, type: :serializer do
  let!(:province) { create(:province)}
  let(:serializer) { ProvinceSerializer.new(province).to_json }

  it 'should be have attribute provinces as root path' do
    expect(serializer).to have_json_size(1)
    expect(serializer).to have_json_type(Object).at_path('province')
  end

  it 'should be have attribute id' do
    expect(serializer).to have_json_path('province/id')
    expect(serializer).to have_json_type(Integer).at_path('province/id')
  end

  it 'should be have attribute name' do
    expect(serializer).to have_json_path('province/name')
    expect(serializer).to have_json_type(String).at_path('province/name')
  end

  it 'should be have attribute description' do
    expect(serializer).to have_json_path('province/description')
    expect(serializer).to have_json_type(String).at_path('province/description')
  end

  it 'should be have attribute districts' do
    expect(serializer).to have_json_path('province/districts')
    expect(serializer).to have_json_type(Array).at_path('province/districts')
  end
end
