class CarePlan < ActiveRecord::Base
    belongs_to :client
    belongs_to :assessment

    has_many  :assessment_domains, dependent: :destroy
    has_many  :goals, dependent: :destroy


    has_paper_trail    

    accepts_nested_attributes_for :goals, reject_if:  proc { |attributes| attributes['description'].blank?}, allow_destroy: true
    accepts_nested_attributes_for :assessment_domains

  end
  