class Carer < ActiveRecord::Base
  belongs_to :province
  belongs_to :district
  belongs_to :commune
  belongs_to :village
  has_many :clients
end
