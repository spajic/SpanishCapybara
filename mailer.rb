module SpanishRobot

module Mailer
  require 'pony'
  Pony.options = { :via => :smtp,
    :via_options => {
      :address              => 'smtp.gmail.com',
      :port                 => '587',#'25',#'587'
      :enable_starttls_auto => true,
      :user_name            => ENV['PONY_MAIL'], # моя почта
      :password             => ENV['PONY_PASSWORD'], # пароль приложения, сгенерированный в gmail
      :authentication       => :plain, # :plain, :login, :cram_md5, no auth by default
      :domain               =>'HELO' # the HELO domain provided by the client to the server
    }
  }

  def self.send_mail(args)
  	Pony.mail(
  	  to: ENV['PONY_MAIL'],
  	  from: ENV['PONY_MAIL'],
  	  subject: args[:subject],
  	  body: args[:body]
  	)
  end
end # module Mailer

end # module SpanishRobot
