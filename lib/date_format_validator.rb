class DateFormatValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)
    value = value.to_s unless value.is_a?(String)
    unless value =~ /\A[0-9]{4}-(?:0[1-9]|1[0-2])-(?:0[1-9]|[12][0-9]|3[0-1])\Z/
      object.errors.add(attribute, :date_format, options)
    end
  end
end
