describe CommuneSerializer, type: :serializer do
  let(:commune) { create(:commune) }
  let(:serializer) { CommuneSerializer.new(commune).to_json }

  it 'commune attribute as root path' do
    expect(serializer).to have_json_size(1)
    expect(serializer).to have_json_type(Object).at_path('commune')
  end

  it 'id attribute' do
    expect(serializer).to have_json_path('commune/id')
    expect(serializer).to have_json_type(Integer).at_path('commune/id')
  end

  it 'name attribute' do
    expect(serializer).to have_json_path('commune/name')
    expect(serializer).to have_json_type(String).at_path('commune/name')
  end

  it 'code attribute' do
    expect(serializer).to have_json_path('commune/code')
    expect(serializer).to have_json_type(String).at_path('commune/code')
  end
end
