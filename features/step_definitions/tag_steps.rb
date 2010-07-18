Given /^I have no tags$/ do
  Tag.delete_all
  silence_warnings {load "#{RAILS_ROOT}/app/models/fandom.rb"}
end

Given /^basic tags$/ do
  Warning.find_or_create_by_name_and_canonical("No Archive Warnings Apply", true)
  Rating.find_or_create_by_name_and_canonical("Not Rated", true)
end

When /^I edit the tag "([^\"]*)"$/ do |tag|
  tag = Tag.find_by_name!(tag)
  visit tag_url(tag)
  click_link_within("Edit", ".header")
end

When /^I view the tag "([^\"]*)"$/ do |tag|
  tag = Tag.find_by_name!(tag)
  visit tag_url(tag)
end

When /^I create the fandom "([^\"]*)" with id (\d+)$/ do |name, id|
 tag = Fandom.new(:name => name)
 tag.id = id.to_i
 tag.canonical = true
 tag.save
end

Given /^I have a canonical "([^\"]*)" fandom tag named "([^\"]*)"$/ do |media, fandom|
  fandom = Fandom.find_or_create_by_name_and_canonical(fandom, true)
  media = Media.find_or_create_by_name_and_canonical(media, true)
  fandom.add_association media
end

Given /^I add the fandom "([^\"]*)" to the character "([^\"]*)"$/ do |fandom, character|
  char = Character.find_or_create_by_name(character)
  fand = Fandom.find_or_create_by_name(fandom)
  char.add_association(fand)
end

