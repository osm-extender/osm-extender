class AddNameAndDatesToProgrammeReviewBalancedCache < ActiveRecord::Migration[4.2]

  def up
    # Add columns
    add_column :programme_review_balanced_caches, :term_name, :string
    add_column :programme_review_balanced_caches, :term_start, :date
    add_column :programme_review_balanced_caches, :term_finish, :date

    # Populate columns (deleting the ones which can't be populated)
    puts "Fetching term names and dates for existing ProgrammeReviewBalancedCache items"
    ProgrammeReviewBalancedCache.reset_column_information
    section_to_user = {}
    puts "\tBuilding map of sections to users"
    User.all.each do |user|
      if user.connected_to_osm?
        Osm::Section.get_all(user.osm_api).each do |section|
          unless section_to_user.keys.include?(section.id)
            if ((user.osm_api.get_user_permissions[section.id] || {})[:programme] || []).include?(:read) &&
               ((Osm::ApiAccess.get_ours(user.osm_api, section.to_i) || {}).permissions[:programme] || []).include?(:read)
                  section_to_user[section.id] = user
            end
          end
        end
      end
    end
    count = ProgrammeReviewBalancedCache.count
    ProgrammeReviewBalancedCache.all.each_with_index do |cache, index|
      puts "\tCached term #{index + 1} of #{count}"
      user = section_to_user[cache.section_id]
      if user.nil?
        # We don't have a user with access to the programme for the section
        cache.destroy
      else
        term = Osm::Term.get(user.osm_api, cache.term_id)
        if term.nil?
          # The term no longer exists in OSM
          cache.destroy
        else
          cache.update_attributes(
            :term_name => term.name,
            :term_start => term.start,
            :term_finish => term.finish,
          )
        end
      end
    end

    # Add in null constraints
    change_column :programme_review_balanced_caches, :term_name, :string, :null => false
    change_column :programme_review_balanced_caches, :term_start, :date, :null => false
    change_column :programme_review_balanced_caches, :term_finish, :date, :null => false
  end

  def down
    remove_column :programme_review_balanced_caches, :term_name
    remove_column :programme_review_balanced_caches, :term_start
    remove_column :programme_review_balanced_caches, :term_finish
  end

end