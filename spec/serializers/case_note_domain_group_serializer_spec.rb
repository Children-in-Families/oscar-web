require 'spec_helper'

describe CaseNoteDomainGroupSerializer, type: :serializer do
  let(:case_note_domain_group) { create(:case_note_domain_group) }
  let(:serializer) { CaseNoteDomainGroupSerializer.new(case_note_domain_group).to_json }

  it 'should be have attribute case_note_domain_group as root path' do
    expect(serializer).to have_json_size(1)
    expect(serializer).to have_json_type(Object).at_path('case_note_domain_group')
  end

  it 'should be have attribute id' do
    expect(serializer).to have_json_path('case_note_domain_group/id')
    expect(serializer).to have_json_type(Integer).at_path('case_note_domain_group/id')
  end

  it 'should be have attribute case_note_id' do
    expect(serializer).to have_json_path('case_note_domain_group/case_note_id')
    expect(serializer).to have_json_type(Integer).at_path('case_note_domain_group/case_note_id')
  end

  it 'should be have attribute note' do
    expect(serializer).to have_json_path('case_note_domain_group/note')
    expect(serializer).to have_json_type(String).at_path('case_note_domain_group/note')
  end

  it 'should be have attribute domain_group_id' do
    expect(serializer).to have_json_path('case_note_domain_group/domain_group_id')
    expect(serializer).to have_json_type(Integer).at_path('case_note_domain_group/domain_group_id')
  end

  it 'should be have attribute tasks' do
    expect(serializer).to have_json_path('case_note_domain_group/tasks')
    expect(serializer).to have_json_type(Array).at_path('case_note_domain_group/tasks')
  end
end
