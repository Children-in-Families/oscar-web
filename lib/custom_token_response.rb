module CustomTokenResponse
  def body
    user_details = User.find(@token.resource_owner_id)
    # call original `#body` method and merge its result with the additional data hash
       super.merge({
           status_code: 200,
           message: I18n.t('devise.sessions.signed_in'),
           result: user_details
       })
  end
end
