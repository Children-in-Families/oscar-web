describe DistrictSerializer, type: :serializer do
  let(:district) { create(:district) }
  let(:serializer) { DistrictSerializer.new(district).to_json }

  it 'district attribute as root path' do
    expect(serializer).to have_json_size(1)
    expect(serializer).to have_json_type(Object).at_path('district')
  end

  it 'id attribute' do
    expect(serializer).to have_json_path('district/id')
    expect(serializer).to have_json_type(Integer).at_path('district/id')
  end

  it 'name attribute' do
    expect(serializer).to have_json_path('district/name')
    expect(serializer).to have_json_type(String).at_path('district/name')
  end

  it 'code attribute' do
    expect(serializer).to have_json_path('district/code')
    expect(serializer).to have_json_type(String).at_path('district/code')
  end
end
