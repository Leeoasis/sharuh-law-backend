class LawyerMailer < ApplicationMailer
  def approval_email(lawyer)
    @lawyer = lawyer
    mail(to: @lawyer.email, subject: "You have been approved")
  end
end
