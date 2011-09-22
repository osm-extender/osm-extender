class MyPageController < ApplicationController
  before_filter :require_login

  def index
  end
  
end
