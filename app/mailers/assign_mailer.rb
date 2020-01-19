class AssignMailer < ApplicationMailer
  default from: 'from@example.com'

  def assign_mail(email, password)
    @email = email
    @password = password
    mail to: @email, subject: I18n.t('views.messages.complete_registration')
  end

  def change_leader_mail(email, team)
    @email = email
    @team = team
    mail to: @email, subject: 'リーダーにアサインされました。'
  end
end