class TaskHistory
  include Mongoid::Document
  include Mongoid::Timestamps

  default_scope { where(tenant: Organization.current.try(:short_name)) }

  field :object, type: Hash
  field :tenant, type: String, default: ->{ Organization.current.short_name }

  embeds_many :case_worker_task_histories

  after_save :create_case_worker_task_history, if: 'object.key?("user_ids")'

  def self.initial(task)
    attributes = task.attributes
    attributes = attributes.merge('user_ids' => task.user_ids) if task.user_ids.any?
    create(object: attributes)
  end

  private

  def create_case_worker_task_history
    object['user_ids'].each do |user_id|
      case_worker = User.find_by(id: user_id).try(:attributes)
      case_worker['current_sign_in_ip'] = case_worker['current_sign_in_ip'].to_s
      case_worker['last_sign_in_ip'] = case_worker['last_sign_in_ip'].to_s
      case_worker_task_histories.create(object: case_worker)
    end
  end
end
