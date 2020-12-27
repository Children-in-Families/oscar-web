class CarePlan < ActiveRecord::Base
    belongs_to :client
    belongs_to :assessment

    has_many  :goals, dependent: :destroy


    has_paper_trail    

    accepts_nested_attributes_for :goals, allow_destroy: true

  end
  