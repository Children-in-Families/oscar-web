class Hotline < ActiveRecord::Base
  belongs_to :call
  belongs_to :client
end