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
      can [:administer, :preview, :sample, :send_email, :re_order], EmailReminder do |reminder|
        reminder.user == user
      end
      can :create, EmailReminder
      can [:preview, :send_email, :show], EmailReminder do |reminder|
        result = false
        reminder.shares.each do |share|
          result = true if share.email_address.downcase.eql?(user.email_address.downcase)
        end
        result
      end

      can :administer, EmailReminderItem do |item|
        can? :administer, item.email_reminder
      end
      can :create, EmailReminderItem

      can [:create, :destroy, :index], EmailReminderShare do |share|
        share.reminder.user == user
      end
      can :resend_shared_with_you, EmailReminderShare do |share|
        share.reminder.user == user  &&  share.pending?
      end

      can [:create, :preview], EmailList
      can [:administer, :get_addresses, :multiple], EmailList do |list|
        list.user == user
      end

      can [:destroy, :destroy_multiple], ProgrammeReviewBalancedCache do |item|
        result = false
        if user.connected_to_osm?
          user.osm_api.get_roles.each do |role|
            result = true if (role.section.id == item.section_id)
          end
        end
        result
      end


      can :hide, Announcement


      # Things user administrators can do
      if user.can_administer_users?
        can [:administer, :reset_password, :unlock], User
        can :resend_activation, User do |user_being_acted_on|
          user_being_acted_on && !user_being_acted_on.activation_token.blank?
        end
      end

      # Things FAQ administrators can do
      if user.can_administer_faqs?
        can [:administer, :re_order], Faq
        can [:administer, :re_order], FaqTag
        can :administer, FaqTaging
      end

      # Things Announcement administrators can do
      if user.can_administer_announcements?
        can :administer, Announcement
      end

      # Things Settings administrators can do
      if user.can_administer_settings?
        can :update, Settings
      end

    end
  end
end
