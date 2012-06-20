class AddFaqTags < ActiveRecord::Migration

  def up
    create_table :faq_tags do |t|
      t.string :name, :null => false

      t.timestamps
    end
    add_index :faq_tags, :name, :unique => true

    create_table :faq_tagings do |t|
      t.references :faq, :null => false
      t.references :faq_tag, :null => false

      t.timestamps
    end
    add_index :faq_tagings, :faq_id
    add_index :faq_tagings, :faq_tag_id


    FaqTag.reset_column_information
    FaqTaging.reset_column_information
    ft_osmx = FaqTag.create(:name => 'Online Scout Manager Extender')
    ft_features = FaqTag.create(:name => 'Features')

    say "Adding tags to FAQs"
    {
      "What's Online Scout Manager Extender" => [ft_osmx],
      "Is it safe to give this site my Online Scout Manager password?" => [ft_osmx],
      "I would like Online Scout Manager Extender to ..." => [ft_osmx],
      "What's the OSM permissions page?" => [ft_features],
      "What's the Email lists feature?" => [ft_features],
      "What's the Programme review feature?" => [ft_features],
      "What's the Email reminder feature?" => [ft_features],
      "What's the Programme wizard feature?" => [ft_features],
    }.each do |key, value|
      say key, true
      faq = Faq.find_by_question(key)
      faq.tags = value
      faq.save
    end
  end


  def down
    drop_table :faq_tags
    drop_table :faq_tagings
  end
end
