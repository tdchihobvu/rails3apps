class UserEmail < ActionMailer::Base
  default from: "norepy@showtime.co.zw"

  def user_email(user,sent_at = Time.now)
    @user = User.find(user)
    @subject = "Showtime OnlineStore Access Granted"
    mail(to: @user.email, subject: @subject)

#    content_type "text/html"
  end
  
  def user_renewal(usr,sent_at = Time.now)
    @user = User.find(usr)
    @subject = "Showtime OnlineStore Access Renewal"
    mail(to: @user.email, subject: @subject)

#    content_type "text/html"
  end


end
