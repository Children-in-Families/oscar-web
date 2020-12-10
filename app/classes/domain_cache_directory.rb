class DomainCacheDirectory
  def self.call(request)
    Rails.root.join("public", request.domain)
  end
end
