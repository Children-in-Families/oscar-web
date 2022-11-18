class Hotline < ApplicationRecord
  belongs_to :call
  belongs_to :client
end
