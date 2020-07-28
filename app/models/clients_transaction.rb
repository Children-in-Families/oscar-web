class ClientsTransaction
  include Mongoid::Document
  include Mongoid::Timestamps

  store_in database: ->{ ENV['PRIMERO_TRANSACTION'] }

  field :_id, type: String
  field :items, type: Array

  protected

  def self.initial(transaction_id, clients)
    attributes = clients
    create(_id: transaction_id, items: attributes) if transaction_id && where(id: transaction_id).first.blank?
  end
end
