xdescribe 'A very large request', type: :request do
  it 'should not overflow cookies' do
    get "/dashboards?foo=#{'x' * ActionDispatch::Cookies::MAX_COOKIE_SIZE}"
    expect(response).to redirect_to '/users/sign_in'
  end
end