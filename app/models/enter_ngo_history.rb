class EnterNgoHistory
  include Mongoid::Document
  include Mongoid::Timestamps

  store_in database: -> { Organization.current.mho? ? ENV['MHO_HISTORY_DATABASE_NAME'] : Rails.configuration.history_database_name }
  default_scope { where(tenant: Organization.current.try(:short_name)) }

  field :object, type: Hash
  field :tenant, type: String, default: -> { Organization.current.short_name }

  embeds_many :enter_ngo_user_histories

  after_save :create_enter_ngo_user_history, if: 'object.key?("user_ids")'

  def self.initial(enter_ngo)
    attributes = enter_ngo.attributes
    attributes = attributes.merge('user_ids' => enter_ngo.user_ids) if enter_ngo.user_ids.any?
    # create(object: attributes)
  end

  private

  def create_enter_ngo_user_history
    object['user_ids'].each do |user_id|
      enter_ngo_user = User.find_by(id: user_id).try(:attributes)
      enter_ngo_user['current_sign_in_ip'] = enter_ngo_user['current_sign_in_ip'].to_s
      enter_ngo_user['last_sign_in_ip'] = enter_ngo_user['last_sign_in_ip'].to_s
      # enter_ngo_user_histories.create(object: enter_ngo_user)
    end
  end
end
