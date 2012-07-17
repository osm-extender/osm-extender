require 'osm/version'
Dir[File.join(File.dirname(__FILE__) , 'osm', '*.rb')].each {|file| require file }


module Osm

  class Error < Exception; end
  class ConnectionError < Error; end


  private
  def self.make_array_of_symbols(array)
    array.each_with_index do |item, index|
      array[index] = item.to_sym
    end
  end

  def self.find_current_term_id(api, section_id, data={})
    terms = api.get_terms(data)

    # Return the term we are currently in
    unless terms.nil?
      terms.each do |term|
        return term.id if (term.section_id == section_id) && term.current?
      end
    end

    raise Error.new('There is no current term for the section.')
  end

  def self.make_datetime(date, time)
    if (!date.blank? && !time.blank?)
      return DateTime.parse((date + ' ' + time), 'yyyy-mm-dd hh:mm:ss')
    elsif !date.blank?
      return DateTime.parse(date, 'yyyy-mm-dd')
    else
      return nil
    end
  end

  def self.parse_date(date)
    begin
      return Date.parse(date, 'yyyy-mm-dd')
    rescue ArgumentError
      return nil
    end
  end


end
