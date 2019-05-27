class CaseWorker
  include Mongoid::Document
  include Mongoid::Timestamps

  store_in collection: "case_workers", database: "history_database"

  field :case_worker_id
  field :object, type: Hash

  def self.initial
    Mongoid.raise_not_found_error = false
    case_worker = CaseWorker.find_by(case_worker_id: self.id)
    if case_worker.present?
      case_worker_attribute = {"name" => "test", "date_of_birth" => "20-02-1998", "gender" => "female"}
      case_worker.update_attributes = case_worker_attribute
    else
      case_worker_attribute = {"name" => "test", "date_of_birth" => "20-02-1998", "gender" => "female"}
      create(object: case_worker_attribute, case_worker_id: 1)
    end
  end
end