# Make it support checking policy_name
# authorize(@client, :show?, :given_name)

Pundit.module_eval do
  protected

  def authorize(record, query = nil, policy_name = nil)
    query ||= params[:action].to_s + "?"

    @_pundit_policy_authorized = true

    policy = policy(record)

    if policy_name.present?
      if !policy.public_send(query, policy_name)
        raise Pundit::NotAuthorizedError, query: query, record: record, policy: policy
      end
    else
      if !policy.public_send(query)
        raise Pundit::NotAuthorizedError, query: query, record: record, policy: policy
      end
    end

    record
  end
end
