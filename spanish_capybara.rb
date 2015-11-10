require 'capybara'
require 'capybara/poltergeist'
require 'pry'
require 'pony'

require_relative 'clients'
require_relative 'command_line_options'
require_relative 'datetime_manager_of_available_citas'

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

def mytime
  (Time.now + 11*3600).strftime("%H:%M:%S")
end

class CaptchaSolverByHand  
  attr_reader :result
  
  def initialize
    @result = ""
  end

  def solve
    # todo: 
    # сохранить капчу в файл и открыть
    print "Enter CAPTHCA value, please: "
    @result = gets.chomp!
    puts "You entered #{@result}, thank you"
    @result
  end
end

class Scenario
  attr_reader :name, :session, :engine, :appointment, :captcha_solver, :steps
  def initialize(name, session, engine, appointment, captcha_solver, steps)
    @name = name
    @session = session
    @engine = engine
    @appointment = appointment
    @captcha_solver = captcha_solver
    @steps = steps
  end

  def step
    puts "STARTING SCENARIO #{name}"
    @steps.each do |step|
      step.scenario = self
      step.on_start
      step.step 
      step.on_finish
    end
    puts "FINISHED SCENARIO #{name}"
      
    rescue => err
      3.times{puts "==================================="}
      puts "RUNTIME ERROR: #{err}"
      print err.backtrace.join("\n")
      puts "Start again!"
      3.times{puts "==================================="}
      retry
  end
end

class Step
  attr_reader :name, :session
  attr_writer :scenario
    
  def initialize(name)
    @FolderToSave = "CapybaraStash-#{mytime}"
    @name = name
  end

  def s()
    @scenario.session
  end
  def appointment()
    @scenario.appointment
  end
  def captcha_solver()
    @scenario.captcha_solver
  end
  def engine()
    @scenario.engine
  end

  def send_mail(subject, body)
    Pony.mail(:to => 'bestspajic@gmail.com', :from => 'bestspajic@gmail.com', 
      :subject => subject, :body => body)
  end

  def save_page()
    path = "#{@FolderToSave}/#{mytime}-#{name}.html"
    s.save_page(path)
    puts "Saved html to #{path}"
  end

  def save_and_open_page()
    path = "#{@FolderToSave}/#{mytime}-#{name}.html"
    s.save_and_open_page(path)
    puts "Saved html to #{path}"
  end
  def save_screenshot()
    s.save_screenshot
    puts "Saved png to root folder"
  end
  def save_and_open_screenshot()
    s.save_and_open_screenshot
    puts "Saved png to root folder and open it"
  end

  def step()
    puts "Define step method"
  end

  def on_start()
    puts "START STEP #{name}"
  end

  def on_finish()
    puts "SUCCESS STEP #{name}"
  end

  def fail_and_exit(message)
    puts "Step #{name} failed with message - #{message}"
    puts "exit now"
    exit(1)
  end

end

class Step0 < Step
  def step
  	s.visit "https://sede.administracionespublicas.gob.es/icpplus/index.html"
    tag_content = "PROVINCIAS DISPONIBLES"
    fail_and_exit("Unable to find tag_content #{tag_content}") unless s.has_content?(tag_content)
  end
end

class StepsBeforePassportBarcelonaRegresso < Step
  def step
      s.select("Barcelona")
      s.click_on("Autorización de Regreso.")
      s.click_on("Autorización de Regreso.") if engine == "selenium"
      s.select "AUTORIZACIONES DE REGRESO"#, :from => "t"
      s.click_on("Aceptar")
      s.click_on("ENTRAR")
  end
end

class StepsBeforePassportBarcelonaExtranjero < Step
  def step
      s.select("Barcelona")
      s.click_on("Expedición de Tarjeta de Identidad de Extranjero.")
      s.click_on("Expedición de Tarjeta de Identidad de Extranjero.") if engine == "selenium"
      s.select "TOMA DE HUELLAS (EXPEDICIÓN DE TARJETA) Y RENOVACIÓN DE TARJETA DE LARGA DURACIÓN"#, :from => "t"
      s.click_on("Aceptar")
      s.click_on("ENTRAR")
  end
end

class StepsBeforePassportMadridRegresso < Step
  def step
      s.select("Madrid")
      s.click_on("Aceptar")
      s.click_on("Aceptar")
      s.select "AUTORIZACIONES DE REGRESO"
      s.click_on("Aceptar")
      s.click_on("ENTRAR")  
  end
end

class StepsBeforePassportMadridExtranjero < Step
  def step
      s.select("Madrid")
      s.click_on("Aceptar")
      s.click_on("Aceptar")
      s.select "TOMA DE HUELLAS (EXPEDICIÓN DE TARJETA) Y RENOVACIÓN DE TARJETA DE LARGA DURACIÓN"
      save_page
      s.click_on("Aceptar")
      s.click_on("ENTRAR")  
  end
end

=begin
class FillPassportRegresso < Step
  def step (session, captcha_solver)
  	s.find(:xpath, '//input[@id="rdbTipoDoc" and @value="PASAPORTE"]').click
    s.fill_in('txtNieAux', :with => '4508906727')
    s.fill_in('txtDesCitado', :with => 'IVAN IVANOV')
    s.fill_in('txtAnnoCitado', :with => '1987')
    s.fill_in('txtFecha', :with => '01/01/2015')
    s.fill_in('txtCaptcha', :with => captcha_solver.solve)
    s.click_on("Aceptar")
  end
end
=end

class FillPassportExtranjero < Step
  def step
    s.find(:xpath, '//input[@id="rdbTipoDoc" and @value="PASAPORTE"]').click
    s.fill_in('txtNieAux', :with => appointment.pasport)
    s.fill_in('txtDesCitado', :with => appointment.name)
    s.select appointment.country
    save_and_open_screenshot
    send_mail('SpanishCapybara', 'Enter Captcha, please!')
    s.fill_in('txtCaptcha', :with => captcha_solver.solve)
    s.click_on("Aceptar")
  end
end

class Step1SolicitarCitaMadrid < Step
  def step
    s.click_on("SOLICITAR CITA")  
    tries = 1
    save_screenshot
    save_page
    sorry_message = 'En este momento no hay citas disponibles.'
    #while s.has_selector?(:xpath, '//input[@value="Siguiente" and @type="button"]', visible: true)
    #Avda. de los Poblados, S/N (MADRID)
    while Capybara.using_wait_time(3) {
        s.has_content?(sorry_message) || 
        (no_office = s.has_no_xpath?('//select/option[text() = "Avda. de los Poblados, S/N (MADRID)"]'))} 
      if no_office
        puts "No sorry message, but no office either" 
        save_page
        save_screenshot
        no_office = false
      end
      puts "#{mytime}, try #{tries} - #{sorry_message} Sleep for #{sleep_time}s and try again!"
      tries += 1
      sleep sleep_time
      s.click_on("Volver")
      s.click_on("SOLICITAR CITA")  
  	end
  	puts "HOORAY!!! Step 1 successfull"
    save_and_open_screenshot
    save_page
    s.click_on("Siguiente")
  end
end

# В отличие от Мадрида нужен конкретный офис: RAMBLA GUIPUSCOA, 74 (BARCELONA)
# <option value="16">RAMBLA GUIPUSCOA, 74 (BARCELONA)</option>
class Step1SolicitarCitaBarcelona < Step
  def step
    s.click_on("SOLICITAR CITA")  
    tries = 1
    save_screenshot
    save_page
    
    sorry_message = 'En este momento no hay citas disponibles.'
    our_office = "RAMBLA GUIPUSCOA, 74 (BARCELONA)"
    no_office = false
    #while s.has_selector?(:xpath, '//input[@value="Siguiente" and @type="button"]', visible: true)
    while Capybara.using_wait_time(3) {
        s.has_content?(sorry_message) || 
        (no_office = s.has_no_xpath?('//select/option[text() = "RAMBLA GUIPUSCOA, 74 (BARCELONA)"]'))} 
      
      if no_office
        puts "No sorry message, but no office either" 
        save_page
        save_screenshot
        no_office = false
      end
      sleep_time = rand 10
      puts "#{mytime}, try #{tries} - #{sorry_message} Sleep for #{sleep_time}s and try again!"
      tries += 1
      sleep sleep_time
      s.click_on("Volver")
      s.click_on("SOLICITAR CITA")  
    end
    puts "HOORAY!!! Step 1 successfull"
    save_and_open_screenshot
    save_page
    s.click_on("Siguiente")
  end
end

class Step2EnterPhoneAndMail < Step
  def step
    s.fill_in('txtTelefonoCitado', :with => appointment.phone)
    s.fill_in('emailUNO', :with => appointment.mail)
    s.fill_in('emailDOS', :with => appointment.mail)
    save_screenshot
    save_page
    s.click_on("Siguiente")
  end
end

class Step3ChooseCita < Step
  def step
    save_and_open_screenshot
    save_page
    puts "Client.date_start: #{appointment.date_start}"
    puts "Client.date_finish: #{appointment.date_finish}"
    dm = DatetimeManagerOfAvailableCitas.new(
      s, appointment.date_start, appointment.date_finish)
    dm.get_available_datetimes_from_session
    if dm.has_appropriate_datetime?
      puts "Has appropriate cita datetime!"
      puts "Has following datetimes: #{dm.datetimes}" 
      puts "Fall in client dates range: #{dm.get_appropriate_datetimes}"  
      puts "Now check option number #{dm.get_first_appropriate_cita_number}"
      dm.choose_first_appropriate_datetime
      s.click_on("Siguiente")
    else
      puts "Has following datetimes: #{dm.datetimes}"
      puts "But nothing is suitable for client!"
      puts "ATTEMPT TO TAKE FIRST ONE ANYWAY!"
      s.find(:xpath, 
        '//input[@type="radio" and @title="Seleccionar CITA 1"]').click
      s.click_on("Siguiente")
    end
  end
end

class Step4Confirm < Step
  def step
    save_and_open_screenshot
    save_page
    s.check('chkTotal')
    s.check('enviarCorreo')
    s.click_on('Confirmar')
  end
end

class Step4WaitUserToConfirm < Step
  def step
    save_and_open_screenshot
    save_page
    s.check('chkTotal')
    s.check('enviarCorreo')
    puts "Robot is waiting. Press enter to confirm, SEND EMAIL THAT NEEDS TO BE ANNULATED, and continue."
    w = gets
    s.click_on('Confirmar')
  end
end

class Step5Final < Step
  def step
    save_and_open_screenshot
    save_page
    if s.has_xpath?('//span[@id="justificanteFinal"]')
      puts "ULTIMATE SUCCESS"
      send_mail("SpanishCapybara", "ULTIMATE SUCCESS!!")
    else
      raise 'FINAL PAGE NOT CONTAINS de justificante de cita:'
    end
  end
end


  # Итоговая страничка с нашим номером, который нам должен быть отправлен на email
  # Nº de Justificante de cita: AB7AF66H
  # <td class="tituloTabla" style="font-size:18px">
  # Nº de Justificante de cita:
  # <span id="justificanteFinal" class="justificanteBold"> AB7AF66H </span>
  # </td>
  #binding.pry
  # session.save_and_open_page 
  
#Capybara.configure do |config|
  #config.match = :one
  #config.exact_options = true
  #config.ignore_hidden_elements = true
  #config.visible_text_only = true
#end


options = SpanishCapybaraOptions.new.get_options(ARGV)

Capybara.default_max_wait_time = options.capybara_default_wait_time
Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, {
    debug: options.poltergeist_debug,
    js_errors: options.poltergeist_js_errors, 
    timeout: options.poltergeist_default_wait_time, 
    phantomjs_options: options.phantomjs_options
    }
  )
end

session = Capybara::Session.new(options.engine)

client_base = ClientsBase.new
appointment = client_base.get_client_by_id(options.client)

unless appointment
  puts "Client with id #{options.client} not found in client_base."
  puts "Exit now"
  exit(1)
end

captcha_solver = CaptchaSolverByHand.new

steps_barcelona_extranjero = [
  Step0.new("0 - visit site"),
  StepsBeforePassportBarcelonaExtranjero.new("Before passport Barcelona Extranjero"),
  FillPassportExtranjero.new("Fill Passport Extranjero"),
  Step1SolicitarCitaBarcelona.new("Multiple Tries to Solicitar Cita"), 
  Step2EnterPhoneAndMail.new("Enter phone and email"),
  Step3ChooseCita.new("Choose Cita"),
  Step4Confirm.new("Confirm and Send Notification to email"),
  Step5Final.new("Wait on Final Page")]

steps_madrid_extranjero = [
  Step0.new("0 - visit site"),
  StepsBeforePassportMadridExtranjero.new("Before passport Madrid Extranjero"),
  FillPassportExtranjero.new("Fill Passport Extranjero"),
  Step1SolicitarCitaMadrid.new("Multiple Tries to Solicitar Cita"), 
  Step2EnterPhoneAndMail.new("Enter phone and email"),
  Step3ChooseCita.new("Choose Cita"),
  Step4WaitUserToConfirm.new("Wait User to Confirm"),
  Step5Final.new("Wait on Final Page")]

steps_scenarios = {
  :BarcelonaExtranjero => steps_barcelona_extranjero, 
  :MadridExtranjero => steps_madrid_extranjero }


SpanishCapybara = Scenario.new(
  "SpanishCapybara", 
  session, 
  options.engine, 
  appointment, 
  captcha_solver, 
  steps_scenarios[options.scenario]
)
SpanishCapybara.step