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
        can [:read, :update, :reset_password, :administer], User
        can :resend_activation, User do |user_being_acted_on|
          user_being_acted_on && !user_being_acted_on.activation_token.blank?
        end
      end

    end
  end
end
