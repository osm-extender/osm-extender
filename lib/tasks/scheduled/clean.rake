namespace :scheduled  do
  namespace :clean  do
    task :all => [:balanced_programme_cache, :announcements, :paper_trails]
  end
end
