require 'spec_helper'

describe FamilySerializer, type: :serializer do
  let(:family) { create(:family, code: nil) }
  let(:serializer) { FamilySerializer.new(family).to_json }

  it 'should be have attribute family as root path' do
    expect(serializer).to have_json_size(1)
    expect(serializer).to have_json_type(Object).at_path('family')
  end

  it 'should be have attribute id' do
    expect(serializer).to have_json_path('family/id')
    expect(serializer).to have_json_type(Integer).at_path('family/id')
  end

  it 'should be have attribute name' do
    expect(serializer).to have_json_path('family/name')
    expect(serializer).to have_json_type(String).at_path('family/name')
  end

  it 'should be have attribute code' do
    expect(serializer).to have_json_path('family/code')
    expect(serializer).to have_json_type(NilClass).at_path('family/code')
  end

  it 'should be have attribute case_history' do
    expect(serializer).to have_json_path('family/case_history')
    expect(serializer).to have_json_type(String).at_path('family/case_history')
  end

  it 'should be have attribute caregiver_information' do
    expect(serializer).to have_json_path('family/caregiver_information')
    expect(serializer).to have_json_type(String).at_path('family/caregiver_information')
  end

  it 'should be have attribute significant_family_member_count' do
    expect(serializer).to have_json_path('family/significant_family_member_count')
    expect(serializer).to have_json_type(Integer).at_path('family/significant_family_member_count')
  end

  it 'should be have attribute household_income' do
    expect(serializer).to have_json_path('family/household_income')
    expect(serializer).to have_json_type(Float).at_path('family/household_income')
  end

  it 'should be have attribute dependable_income' do
    expect(serializer).to have_json_path('family/dependable_income')
    expect(serializer).to have_json_type(:boolean).at_path('family/dependable_income')
  end

  it 'should be have attribute female_children_count' do
    expect(serializer).to have_json_path('family/female_children_count')
    expect(serializer).to have_json_type(Integer).at_path('family/female_children_count')
  end

  it 'should be have attribute male_children_count' do
    expect(serializer).to have_json_path('family/male_children_count')
    expect(serializer).to have_json_type(Integer).at_path('family/male_children_count')
  end

  it 'should be have attribute female_adult_count' do
    expect(serializer).to have_json_path('family/female_adult_count')
    expect(serializer).to have_json_type(Integer).at_path('family/female_adult_count')
  end

  it 'should be have attribute male_adult_count' do
    expect(serializer).to have_json_path('family/female_children_count')
    expect(serializer).to have_json_type(Integer).at_path('family/female_children_count')
  end

  it 'should be have attribute family_type' do
    expect(serializer).to have_json_path('family/family_type')
    expect(serializer).to have_json_type(String).at_path('family/family_type')
  end

  it 'should be have attribute contract_date' do
    expect(serializer).to have_json_path('family/contract_date')
    expect(serializer).to have_json_type(String).at_path('family/contract_date')
  end

  it 'should be have attribute address' do
    expect(serializer).to have_json_path('family/address')
    expect(serializer).to have_json_type(String).at_path('family/address')
  end

  it 'should be have attribute province' do
    expect(serializer).to have_json_path('family/province')
    expect(serializer).to have_json_type(Object).at_path('family/province')
  end

  it 'should be have attribute clients' do
    expect(serializer).to have_json_path('family/clients')
    expect(serializer).to have_json_type(Array).at_path('family/clients')
  end

  it 'should be have attribute add_forms' do
    expect(serializer).to have_json_path('family/add_forms')
    expect(serializer).to have_json_type(Array).at_path('family/add_forms')
  end

  it 'should be have attribute additional_form' do
    expect(serializer).to have_json_path('family/additional_form')
    expect(serializer).to have_json_type(Array).at_path('family/additional_form')
  end
end
