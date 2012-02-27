class Settings
  
  def self.setup
    @@values = {}
    SettingValue.all.each do |value|
      @@values[value.key] = value.value
    end
  end

  def self.read(key)
    self.setup if defined?(@@values).nil?
    @@values[key]
  end

  def self.write(key, value)
    @@values[key] = value

    cv = SettingValue.find_by_key(key)
    cv = SettingValue.create(:key => key) if cv.nil?
    cv.value = value
    cv.save
  end

end
