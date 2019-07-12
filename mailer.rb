
ActionMailer::Base.view_paths = File.dirname(__FILE__)

ActionMailer::Base.smtp_settings = {
 address:    "smtp.gmail.com",
 port:       '587',
 user_name:  ENV['email'],
 password:   ENV['password'],
 authentication: :plain
}

class Newsletter < ActionMailer::Base
   default from: "from@example.com"
   def signup(recipient)
     $username = recipient
     mail(to: recipient, subject: 'Welcome to Rumblr')
   end
end
