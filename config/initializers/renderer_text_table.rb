ActionController::Renderers.add :text_table do |data, options|
  keys = options.delete(:order)

  if data.is_a?(Array)
    rows = data

  elsif data.is_a?(Hash)
    rows = []
    keys ||= data.keys
    keys.each do |key|
      next if key.eql?(:total)
      rows.push [key.to_s.titleize, data[key]]
    end
    if data[:total]
      rows.push :separator
      rows.push ['Total', data[:total]]
    end

  else
    rows = [[data]]
  end

  table = Terminal::Table.new do |t|
    t.headings = options[:headings] if options[:headings]
    rows.each do |row|
      t.add_row row if row.is_a?(Array)
      t.add_row row.values_at(*keys) if row.is_a?(Hash)
      t.add_separator if row.eql?(:separator)
    end
  end
  send_data table.to_s, disposition: :inline, type: Mime[:text_table]
end
