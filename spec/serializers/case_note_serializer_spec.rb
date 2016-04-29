require 'spec_helper'

describe CaseNoteSerializer, type: :serializer do
  let(:case_note) { create(:case_note) }
  let(:serializer) { CaseNoteSerializer.new(case_note).to_json }

  it 'should be have attribute case_note as root path' do
    expect(serializer).to have_json_size(1)
    expect(serializer).to have_json_type(Object).at_path('case_note')
  end

  it 'should be have attribute id' do
    expect(serializer).to have_json_path('case_note/id')
    expect(serializer).to have_json_type(Integer).at_path('case_note/id')
  end

  it 'should be have attribute attendee' do
    expect(serializer).to have_json_path('case_note/attendee')
    expect(serializer).to have_json_type(String).at_path('case_note/attendee')
  end

  it 'should be have attribute meeting_date' do
    expect(serializer).to have_json_path('case_note/meeting_date')
    expect(serializer).to have_json_type(String).at_path('case_note/meeting_date')
  end

  it 'should be have attribute assessment_id' do
    expect(serializer).to have_json_path('case_note/assessment_id')
    expect(serializer).to have_json_type(NilClass).at_path('case_note/assessment_id')
  end

  it 'should be have attribute case_note_domain_groups' do
    expect(serializer).to have_json_path('case_note/case_note_domain_groups')
    expect(serializer).to have_json_type(Array).at_path('case_note/case_note_domain_groups')
  end
end

