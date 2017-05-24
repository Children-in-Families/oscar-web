class Version
  include Mongoid::Document

  field :object, type: Hash

  def self.initial(obj)
    binding.pry
    v = Version.new(object: obj.attributes)
    v.save
  end
end

  