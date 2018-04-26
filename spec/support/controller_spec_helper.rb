module ControlerSpecHelper

  def signin(user, **options)
    user = user.is_a?(Symbol) ? create(user, **options) : user
    allow(controller).to receive(:current_user).and_return(user)
  end

end
            