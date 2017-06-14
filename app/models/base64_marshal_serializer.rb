class Base64MarshalSerializer

  def self.load(value)
    return nil if value.blank?
    Marshal.load(Base64.decode64(value))
  end

  def self.dump(value)
    Base64.encode64(Marshal.dump(value))
  end

end
