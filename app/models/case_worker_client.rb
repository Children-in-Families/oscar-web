class CaseWorkerClient < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid

  belongs_to :user
  belongs_to :client

  after_commit :flush_cache

  private

  def flush_cache
    User.cach_has_clients_case_worker_options(reload: true)
  end
end
