class ClientsTransaction
  include Mongoid::Document
  include Mongoid::Timestamps

  store_in database: ->{ ENV['PRIMERO_TRANSACTION'] }

  field :transaction_id, type: String
  field :object, type: Hash

  protected

  def self.initial(transaction_id, clients)
    attributes = clients
    attributes['transaction_id'] = transaction_id
    attributes['properties'] = format_property(attributes)
    create(object: attributes)
  end

  def self.format_property(attributes)
    mappings = {}
    attributes['properties'].each do |k, v|
      mappings[k] = k.gsub(/(\s|[.])/, '_')
    end
    attributes['properties'].map {|k, v| [mappings[k].downcase, v] }.to_h
  end
end
