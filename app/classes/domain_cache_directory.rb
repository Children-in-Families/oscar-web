class DomainCacheDirectory
  def self.call(request)
    Rails.root.join("public", request.base_url.gsub(/http(s)?\:\/\//, ''))
  end
end
