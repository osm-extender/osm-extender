class SessionsController < ApplicationController

  def new
  end

  def create
    user = login(params[:email_address].downcase, params[:password])
    if user
      redirect_back_or_to my_page_path, :notice => 'Sucessfully signed in.'
    else
      user = User.find_by_email_address(params[:email_address].downcase)
      if user && user.activation_state.eql?('pending')
        flash[:error] = 'You have not yet activated your account.'
      elsif user && !user.lock_expires_at.nil?
        flash[:error] = 'The account was locked.'
      else
        flash[:error] = 'Email address or password was invalid.'
      end
      render :new
    end
  end
  
  def destroy
    logout
    redirect_to root_url, :notice => 'Sucessfully signed out.'
  end

end
