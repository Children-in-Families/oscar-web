class CaseWorkerSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :start_date, :job_title, :department, :mobile, :date_of_birth, :email

  has_many :clients
end
