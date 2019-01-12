if File.basename($0) == "rake"
  PaperTrail.request.whodunnit = "rake: #{`whoami`.strip}\targs: #{ARGV.join ' '}"
end

PaperTrail.enabled = true
