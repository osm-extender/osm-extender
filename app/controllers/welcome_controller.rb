class WelcomeController < ApplicationController
  before_filter :require_login, :only => :my_page

  def index
  end
  
  def my_page
  end

end
