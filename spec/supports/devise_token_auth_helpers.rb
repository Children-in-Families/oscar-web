module DeviseTokenAuthHelpers
 def sign_in(user)
    @auth_headers = user.create_new_auth_token
  end
end
