module Osm

  class Section

    attr_reader :id, :name, :subscription_level, :subscription_expires, :type, :num_scouts, :has_badge_records, :has_programme, :wizard, :column_names, :fields, :intouch_fields, :mobile_fields, :extra_records, :role

    # Initialize a new SectionConfig using the hash returned by the API call
    # @param id the section ID used by the API to refer to this section
    # @param data the hash of data for the object returned by the API
    def initialize(id, name, data, role)
      subscription_levels = [:bronze, :silver, :gold]
      subscription_level = data['subscription_level'].to_i - 1

      @id = id.to_i
      @name = name
      @subscription_level = (subscription_levels[subscription_level] unless subscription_level < 0) || :unknown
      @subscription_expires = data['subscription_expires'] ? Date.parse(data['subscription_expires'], 'yyyy-mm-dd') : nil
      @type = !data['sectionType'].nil? ? data['sectionType'].to_sym : :unknown
      @num_scouts = data['numscouts']
      @has_badge_records = data['hasUsedBadgeRecords'].eql?('1') ? true : false
      @has_programme = data['hasProgramme']
      @wizard = (data['wizard'] || '').downcase.eql?('true') ? true : false
      @column_names = (data['columnNames'] || {}).symbolize_keys
      @fields = (data['fields'] || {}).symbolize_keys
      @intouch_fields = (data['intouch'] || {}).symbolize_keys
      @mobile_fields = (data['mobFields'] || {}).symbolize_keys
      @extra_records = data['extraRecords'] || []
      @role = role

      # Symbolise the keys in each hash of the extra_records array
      @extra_records.each do |item|
        # Expect item to be: {:name=>String, :extraid=>FixNum}
        # Sometimes get item as: [String, {"name"=>String, "extraid"=>FixNum}]
        if item.is_a?(Array)
          item = item[1].symbolize_keys
        else
          item.symbolize_keys!
        end
      end
    end

    def youth_section?
      [:beavers, :cubs, :scouts, :explorers].include?(@type)
    end

    # Custom section type checkers
    [:beavers, :cubs, :scouts, :explorers, :adults, :waiting].each do |attribute|
      define_method "#{attribute}?" do
        @type == attribute
      end
    end

    def <=>(another_section)
      self.role <=> another_section.try(:role)
    end

    def ==(another_section)
      self.id == another_section.try(:id)
    end

  end

end
