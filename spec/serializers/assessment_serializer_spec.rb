require 'spec_helper'

RSpec.describe AssessmentSerializer, type: :serializer do
  let(:assessment) { create(:assessment) }
  let(:serializer) { AssessmentSerializer.new(assessment).to_json }

  it 'should be have attribute assessment as root path' do
    expect(serializer).to have_json_size(1)
    expect(serializer).to have_json_type(Object).at_path('assessment')
  end

  it 'should be have attribute id' do
    expect(serializer).to have_json_path('assessment/id')
    expect(serializer).to have_json_type(Integer).at_path('assessment/id')
  end

  it 'should be have attribute client_id' do
    expect(serializer).to have_json_path('assessment/client_id')
    expect(serializer).to have_json_type(Integer).at_path('assessment/client_id')
  end

  it 'should be have attribute created_at' do
    expect(serializer).to have_json_path('assessment/created_at')
    expect(serializer).to have_json_type(String).at_path('assessment/created_at')
  end

  it 'should be have attribute updated_at' do
    expect(serializer).to have_json_path('assessment/updated_at')
    expect(serializer).to have_json_type(String).at_path('assessment/updated_at')
  end

  it 'should be have attribute case_notes' do
    expect(serializer).to have_json_path('assessment/case_notes')
    expect(serializer).to have_json_type(Array).at_path('assessment/case_notes')
  end

  xit 'should be have attribute assessment_domains' do
    expect(serializer).to have_json_path('assessment/assessment_domains')
    expect(serializer).to have_json_type(Array).at_path('assessment/assessment_domains')
  end
end