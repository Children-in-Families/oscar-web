class GovernmentFormDecorator < Draper::Decorator
  delegate_all

  def case_worker_name
    client.users.distinct.find_by(id: case_worker_id).try(:name)
  end

  def case_worker_phone
    client.users.distinct.find_by(id: case_worker_id).try(:mobile)
  end
end
