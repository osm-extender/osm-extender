module SessionHelper

  def show_paypal_donation?
    first_time = (2017 * 12) + 9 # September 2017
    frequency = 7                # Months
    today = (Date.today.year * 12 + Date.today.month)
    ((today - first_time) % frequency).eql?(0)
  end

end                    