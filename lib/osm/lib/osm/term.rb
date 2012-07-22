module Osm

  class Term

    attr_reader :id, :section_id, :name, :start, :end

    # Initialize a new Term using the hash returned by the API call
    # @param data the hash of data for the object returned by the API
    def initialize(data)
      @id = data['termid'].to_i
      @section_id = data['sectionid'].to_i
      @name = data['name']
      @start = Osm::parse_date(data['startdate'])
      @end = Osm::parse_date(data['enddate'])
    end

    # Determine if the term is completly before the passed date
    # @param date
    # @returns true if the term is completly before the passed date
    def before?(date)
      return @end < date.to_date
    end

    # Determine if the term is completly after the passed date
    # @param date
    # @returns true if the term is completly after the passed date
    def after?(date)
      return @start > date.to_date
    end

    # Determine if the term is in the future
    # @returns true if the term starts after today
    def future?
      return @start > Date.today
    end

    # Determine if the term is in the past
    # @returns true if the term finished before today
    def past?
      return @end < Date.today
    end

    # Determine if the term is current
    # @returns true if the term started before today and finishes after today
    def current?
      return (@start <= Date.today) && (@end >= Date.today)
    end

    # Determine if the provided date is within the term
    # @param date the date to test
    # @returns true if the term started before the date and finishes after the date
    def contains_date?(date)
      return (@start <= date) && (@end >= date)
    end

    def <=>(another_term)
      compare = self.section_id <=> another_term.try(:section_id)
      return compare unless compare == 0

      compare = self.start <=> another_term.try(:start)
      return compare unless compare == 0

      self.id <=> another_term.try(:id)
    end

    def ==(another_term)
      self.id == another_term.try(:id)
    end

  end

end
