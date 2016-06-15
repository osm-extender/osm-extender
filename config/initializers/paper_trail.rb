if File.basename($0) == "rake"
  PaperTrail.whodunnit = "rake: #{`whoami`.strip}\targs: #{ARGV.join ' '}"
end

PaperTrail.config.track_associations = false
PaperTrail.enabled = true
