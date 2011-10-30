require File.dirname(__FILE__) + '/spec_helper'
require 'capybara/rspec'

require 'capybara/dsl'
require 'pathname'

ROOT = File.expand_path(File.join(File.dirname(__FILE__), ".."))
APP_DATA_DIR = File.join(ROOT, "data")
TEST_DATA_DIR = File.join(ROOT, 'spec/data')

class TestApp < Controller
  def self.data_root
    TEST_DATA_DIR
  end
end

# Capybara.register_driver :selenium do |app|
#   Capybara::Selenium::Driver.new(app, :resynchronize => true)
# end

Capybara.app = TestApp

RSpec.configure do |config|
  config.include Capybara::DSL
end

describe "loading a page" do
  before do
    `rm -rf #{TEST_DATA_DIR}`
    Capybara.current_driver = :selenium
  end

  it "should load the welcome page" do
    visit("/")
    body.should include("Welcome Visitors")
  end

  it "should copy welcome-visitors from the default-data to data" do
    File.exist?(File.join(TEST_DATA_DIR, "pages/welcome-visitors")).should == false
    visit("/")
    body.should include("Welcome Visitors")
    File.exist?(File.join(TEST_DATA_DIR, "pages/welcome-visitors")).should == true
  end

end

# describe "retrieving favicon" do
#   before do
#     `rm -rf #{TEST_DATA_DIR}`
#     Capybara.current_driver = :selenium
#   end
#   it "should return the default image when no other image is present" do
#     File.exist?(File.join(TEST_DATA_DIR, "status/favicon.png")).should == false
#     visit("/favicon.png")
#     body.shound include("favicon.png (PNG Image, 32x32 pixels)") #firefox generated
#   end
# end

class Capybara::Node::Element
  def double_click
    driver.browser.mouse.double_click(native)
  end

  TRIGGER_JS = "$(arguments[0]).trigger(arguments[1]);"
  def trigger(event)
    driver.browser.execute_script(TRIGGER_JS, native, event)
  end
end

describe "edit paragraph in place" do
  before do
    `rm -rf #{TEST_DATA_DIR}`
    Capybara.current_driver = :selenium
    visit("/")
  end

  def first_paragraph
    page.find(".paragraph:first")
  end

  def double_click_paragraph
    first_paragraph.double_click
  end

  def text_area
    first_paragraph.find("textarea")
  end

  def replace_and_save(value)
    text_area.set value
    text_area.trigger "focusout"
  end

  def journal
    page.find(".journal").all(".action")
  end


  it "should turn into a text area, showing wikitext when double-clicking" do
    double_click_paragraph
    text_area.value.should include("Welcome to the [[Smallest Federated Wiki]]")
  end

  it "should save changes to wiki text when unfocused" do
    double_click_paragraph
    replace_and_save("The [[quick brown]] fox.")
    first_paragraph.text.should include("The quick brown fox")
  end

  it "should record edit in the journal" do
    j = journal.length
    double_click_paragraph
    replace_and_save("The [[quick brown]] fox.")
    journal.length.should == j+1
  end

end