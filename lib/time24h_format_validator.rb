class Time24hFormatValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)
    if !options[:allow_blank] && value.blank?
      unless value =~ /\A(?:[0-1][0-9]|2[0-3]):[0-5][0-9]\Z/
        object.errors.add(attribute, :time24h_format, options)
      end
    end
  end
end
