require 'spec_helper'


describe "As an administrator I want to edit a contentable item" do

  before do
    @default_language = Alchemy::Language.get_default
    @default_language_root = Factory(:language_root_page, :language => @default_language, :name => 'Home')
    @admin_user = Factory(:admin_user)
  end

  it "can open contentable editor and fill in headline- and text-element" do
    visit '/admin'
    fill_in('alchemy_user_session_login', :with => 'jdoe')
    fill_in('alchemy_user_session_password', :with => 's3cr3t')
    click_on('Login')

    visit '/admin/products'
    click_on 'edit content'
    fill_in 'Headline', :with => 'My Headline'
    click_on 'save'
    fill_in 'Text', :with => 'My Text'
    click_on 'save'

    page.should have_content 'element saved'

    click_on 'publish'

    page.should have_content 'published'
  end

end

feature "As a guest I want to read a contentable item's content" do

  background do
    @default_language = Alchemy::Language.get_default
    @default_language_root = Factory(:language_root_page, :language => @default_language, :name => 'Home')
  end

  scenario "visit contentable and show content" do
    visit '/product/1'
    save_and_open_page
    page.should have_content 'My Headline'
    page.should have_content 'My Text'
  end

end