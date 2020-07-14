module CustomTokenErrorResponse
  def body
    {
      status_code: 401,
      message: I18n.t('devise.failure.unauthenticated', authentication_keys: User.authentication_keys.join('/')),
      result: []
    }
  end
end
