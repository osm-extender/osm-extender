class RemoveOsmSettings < ActiveRecord::Migration
  def prompt(question, test_answer)
    return test_answer if Rails.env.test?
    STDOUT.puts question
    STDOUT.print "> "
    STDIN.gets.strip
  end

  def up
    setting_keys = ['OSM API - id', 'OSM API - token', 'OSM API - name']
    setting_keys.each do |key|
      sv = SettingValue.find_by_key(key)
      sv.destroy unless sv.nil?
    end
  end

  def down
    settings = [
      {
        :prompt => 'What is the OSM API ID to use',
        :key => 'OSM API - id',
        :description => 'The ID you got from Ed at OSM',
      },{
        :prompt => 'What is the OSM API token to use',
        :key => 'OSM API - token',
        :description => 'The token you got from Ed at OSM',
      },{
        :prompt => "What is the name displayed on OSM's External Access tab for this API",
        :key => 'OSM API - name',
        :description => "The name your API has on OSM's External Access tab",
      }
    ]
    settings.each do |setting|
      sv = SettingValue.find_or_create_by_key(setting[:key])
      sv.description = setting[:description]
      sv.value = setting[:value] || prompt(setting[:prompt], '') unless sv.persisted?
      sv.save!
    end
  end
end
