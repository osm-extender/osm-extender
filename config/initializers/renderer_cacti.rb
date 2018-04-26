ActionController.add_renderer :cacti do |data, options|
  if data.is_a?(Hash)
    data = data
           .map{ |k,v| "#{k.to_s.downcase.gsub(/\W/, '_')}:#{v}"}
          .join(' ')
  elsif data.is_a?(Array)
    data = data
           .map{ |k,v| "#{k.to_s.downcase.gsub(/\W/, '_')}:#{v}"}
          .join(' ')
  end

  send_data (data.to_s + "\n"), disposition: :inline, type: Mime::CACTI
end
