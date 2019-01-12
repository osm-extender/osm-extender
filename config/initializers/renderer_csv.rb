ActionController::Renderers.add :csv do |data, options|
  if options.has_key?(:order)
    keys = options.delete(:order)
  end

  if data.is_a?(Hash)
    if keys.nil?
      keys = data.keys - [:total]
      keys.push(:total) if data.has_key?(:total)
    end
    data = [data.values_at(*keys)]

  elsif data.is_a?(Array)
    # Nothing special to do

  elsif data.respond_to?(:to_csv)
    send_data data.to_csv(options), disposition: :inline, type: Mime[:csv] and return
  else
    data = [[data.to_s]]
  end

  options[:headers] ||= options.delete(:headings)
  options[:headers] ||= keys.map{ |h| h.to_s.titleize } unless keys.nil?
  options[:write_headers] = options.has_key?(:headers) unless options.has_key?(:write_headers)
  options = options.slice(:col_sep, :force_quotes, :headers, :quote_char, :skip_blanks, :write_headers)

  send_data(
    CSV.generate(options) { |csv|
      data.each { |row|
        csv << row if row.is_a?(Array)
        csv << row.values_at(*keys) if row.is_a?(Hash)
      }
    },
    disposition: :inline,
    type: Rails.env.development? ? Mime[:text] : Mime[:csv]
  )
end
