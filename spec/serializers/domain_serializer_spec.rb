require 'spec_helper'

describe DomainSerializer, type: :serializer do
  let(:domain_group) { create(:domain_group) }
  let!(:domain) { create(:domain, domain_group: domain_group)}
  let(:serializer) { DomainSerializer.new(domain).to_json }

  it 'should be have attribute id' do
    expect(serializer).to have_json_path('domain/id')
    expect(serializer).to have_json_type(Integer).at_path('domain/id')
  end

  it 'should be have attribute name' do
    expect(serializer).to have_json_path('domain/name')
    expect(serializer).to have_json_type(String).at_path('domain/name')
  end

  it 'should be have attribute identity' do
    expect(serializer).to have_json_path('domain/identity')
    expect(serializer).to have_json_type(String).at_path('domain/identity')
  end

  it 'should be have attribute description' do
    expect(serializer).to have_json_path('domain/description')
    expect(serializer).to have_json_type(String).at_path('domain/description')
  end

  it 'should be have attribute score_1' do
    expect(serializer).to have_json_path('domain/score_1')
    expect(serializer).to have_json_type(Object).at_path('domain/score_1')
  end

  it 'should be have attribute score_2' do
    expect(serializer).to have_json_path('domain/score_2')
    expect(serializer).to have_json_type(Object).at_path('domain/score_2')
  end

  it 'should be have attribute score_3' do
    expect(serializer).to have_json_path('domain/score_3')
    expect(serializer).to have_json_type(Object).at_path('domain/score_3')
  end

  it 'should be have attribute score_4' do
    expect(serializer).to have_json_path('domain/score_4')
    expect(serializer).to have_json_type(Object).at_path('domain/score_4')
  end
end
