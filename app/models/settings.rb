class Settings
  
  def self.setup
    @@values = {}
    SettingValue.all.each do |value|
      @@values[value.key] = value.value
    end
    @@last_read = Time.now
  end

  def self.read(key)
    self.setup  if defined?(@@values).nil? || self.too_old?
    @@values[key]
  end

  def self.write(key, value)
    @@values[key] = value

    cv = SettingValue.find_by_key(key)
    cv = SettingValue.create(:key => key) if cv.nil?
    cv.value = value
    cv.save
  end


  private
  def self.too_old?
    maximum_age = (@@values['maximum settings age'] || '15 minutes')
    @@last_read < maximum_age.split.inject { |count, unit| count.to_i.send(unit).ago }
  end
end
