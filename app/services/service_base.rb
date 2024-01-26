class ServiceBase
  def self.call(*args, &block)
    new(*args, &block).call
  end

  def call
    raise NotImplementedError
  end
end
