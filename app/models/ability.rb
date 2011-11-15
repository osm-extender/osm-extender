# Default aliases:
  # * alias_action :index, :show, :to => :read
  # * alias_action :new, :to => :create
  # * alias_action :edit, :to => :update

class Ability
  include CanCan::Ability
  
  def initialize(user)
    # Things everyone can do

    unless user
      # Things only non authenticated users can do
      can [:new, :create, :activate_account], User

    else
      # Things only authenticated users can do

      # Things user administrators can do
      if user.can_administer_users?
        can [:read, :index, :manage, :reset_password], User
      end

    end
  end
end
