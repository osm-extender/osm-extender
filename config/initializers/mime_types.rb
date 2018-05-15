# Be sure to restart your server when you modify this file.

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf
# Mime::Type.register_alias "text/html", :iphone

Mime::Type.register "text/csv", :csv
Mime::Type.register 'text/tsv', :tsv
Mime::Type.register Mime::TEXT, :cacti
Mime::Type.register Mime::TEXT, :text_table
