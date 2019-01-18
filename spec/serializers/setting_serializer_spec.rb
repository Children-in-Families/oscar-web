require 'spec_helper'

describe SettingSerializer, type: :serializer do
  let!(:setting) { create(:setting) }
  let(:serializer) { SettingSerializer.new(setting).to_json }

  it 'setting as root path' do
    expect(serializer).to have_json_size(1)
    expect(serializer).to have_json_type(Object).at_path('setting')
  end

  it 'id attribute' do
    expect(serializer).to have_json_path('setting/id')
    expect(serializer).to have_json_type(Integer).at_path('setting/id')
  end

  it 'assessment_frequency attribute' do
    expect(serializer).to have_json_path('setting/assessment_frequency')
    expect(serializer).to have_json_type(String).at_path('setting/assessment_frequency')
  end

  it 'max_assessment attribute' do
    expect(serializer).to have_json_path('setting/max_assessment')
    expect(serializer).to have_json_type(Integer).at_path('setting/max_assessment')
  end

  it 'max_case_note attribute' do
    expect(serializer).to have_json_path('setting/max_case_note')
    expect(serializer).to have_json_type(Integer).at_path('setting/max_case_note')
  end

  it 'case_note_frequency attribute' do
    expect(serializer).to have_json_path('setting/case_note_frequency')
    expect(serializer).to have_json_type(String).at_path('setting/case_note_frequency')
  end

  it 'age attribute' do
    expect(serializer).to have_json_path('setting/age')
    expect(serializer).to have_json_type(Integer).at_path('setting/age')
  end

  it 'custom_assessment attribute' do
    expect(serializer).to have_json_path('setting/custom_assessment')
    expect(serializer).to have_json_type(String).at_path('setting/custom_assessment')
  end

  it 'enable_custom_assessment attribute' do
    expect(serializer).to have_json_path('setting/enable_custom_assessment')
    expect(serializer).to have_json_type(:boolean).at_path('setting/enable_custom_assessment')
  end

  it 'enable_default_assessment attribute' do
    expect(serializer).to have_json_path('setting/enable_default_assessment')
    expect(serializer).to have_json_type(:boolean).at_path('setting/enable_default_assessment')
  end

  it 'max_custom_assessment attribute' do
    expect(serializer).to have_json_path('setting/max_custom_assessment')
    expect(serializer).to have_json_type(Integer).at_path('setting/max_custom_assessment')
  end

  it 'custom_assessment_frequency attribute' do
    expect(serializer).to have_json_path('setting/custom_assessment_frequency')
    expect(serializer).to have_json_type(String).at_path('setting/custom_assessment_frequency')
  end

  it 'custom_age attribute' do
    expect(serializer).to have_json_path('setting/custom_age')
    expect(serializer).to have_json_type(Integer).at_path('setting/custom_age')
  end

  it 'default_assessment attribute' do
    expect(serializer).to have_json_path('setting/default_assessment')
    expect(serializer).to have_json_type(String).at_path('setting/default_assessment')
  end
end
