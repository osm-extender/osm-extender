# Default aliases:
  # * alias_action :index, :show, :to=>:read
  # * alias_action :new, :to=>:create
  # * alias_action :edit, :to=>:update

class Ability
  include CanCan::Ability
  
  def initialize(user)
    alias_action :destroy, :to=>:delete
    alias_action :create, :read, :update, :delete, :to=>:administer

    # Things everyone can do
    can :list, Faq

    unless user
      # Things only non authenticated users can do
      can [:new, :create, :activate_account], User

    else
      # Things only authenticated users can do
      can [:administer, :preview, :send_email], EmailReminder do |reminder|
        reminder.user == user
      end
      can :create, EmailReminder

      can :administer, EmailReminderItem do |item|
        can? :administer, item.email_reminder
      end
      can :create, EmailReminderItem

      can [:administer, :get_addresses], EmailList do |list|
        list.user == user
      end
      can [:create, :preview], EmailList
      can [:destroy, :destroy_multiple], ProgrammeReviewBalancedCache do |item|
        result = false
        if user.connected_to_osm?
          user.osm_api.get_roles.each do |role|
            result = true if (role.section.id == item.section_id)
          end
        end
        result
      end

      # Things user administrators can do
      if user.can_administer_users?
        can [:read, :update, :reset_password, :administer], User
        can :resend_activation, User do |user_being_acted_on|
          user_being_acted_on && !user_being_acted_on.activation_token.blank?
        end
      end

      # Things FAQ administrators can do
      if user.can_administer_faqs?
        can :administer, Faq
      end

      # Things Settings administrators can do
      if user.can_administer_settings?
        can :update, Settings
      end

    end
  end
end
