require File.join(File.dirname(__FILE__), '..', 'version')
Dir[File.join(File.dirname(__FILE__) , 'osm', '*.rb')].each {|file| require file }

require 'date'


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
    date = nil if date.nil? || date.empty?
    time = nil if time.nil? || time.empty?
    if (!date.nil? && !time.nil?)
      begin
        return DateTime.strptime((date + ' ' + time), '%Y-%m-%d %H:%M:%S')
      rescue ArgumentError
        return nil
      end
    elsif !date.nil?
      begin
        return DateTime.strptime(date, '%Y-%m-%d')
      rescue ArgumentError
        return nil
      end
    else
      return nil
    end
  end

  def self.parse_date(date)
    return nil if date.nil?
    begin
      return Date.strptime(date, '%Y-%m-%d')
    rescue ArgumentError
      return nil
    end
  end


end
