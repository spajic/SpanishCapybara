require 'capybara'
class DatetimeManagerOfAvailableCitas
=begin
# На странице может быть несколько вариантов CITA на выбор
# Я пока встречал от 1 до 3
# Каждый вариант имет следующий вид:
    <td id="cita_1" style="border: 1px solid #006699; border-bottom:0px; text-align:center; font-size:11px" class="filaoscura" width="30%">
      <span style="font-size:11px; font-weight:bold;text-decoration:underline; line-height: 20pt">
               CITA 1</span>
      <br>
      DÃ­a: 16/12/2015
      <br>
      Hora: 13:20
    </td>
=end

  attr_reader :datetimes
  attr_accessor :client_date_start, :client_date_finish, :session

  def initialize(session, client_date_start, client_date_finish)
    self.session = session
    self.client_date_start = client_date_start
    self.client_date_finish = client_date_finish
  end

  def date_in_client_range?(d)
    d >= client_date_start and d <= client_date_finish
  end

  def get_available_datetimes_from_session
    @datetimes = []
    n = 1
    s = @session
    until Capybara.using_wait_time(3){
    s.has_no_xpath? ("//td[@id='cita_#{n}']") }
      c = s.find(:xpath, "//td[@id='cita_#{n}']")
      m = /(\d\d)\/(\d\d)\/(\d{4})/.match(c.text)
      dd, mm, yy = m[1].to_i, m[2].to_i, m[3].to_i
      m2 = /(\d\d):(\d\d)/.match(c.text)
      hour, minutes = m2[1].to_i, m2[2].to_i
      datetimes.push DateTime.new(yy,mm,dd,hour,minutes)
      n += 1
    end
  end
  private :get_available_datetimes_from_session

  def has_appropriate_datetime?
    #binding.pry
    datetimes.any? &method(:date_in_client_range?)
  end

  def get_appropriate_datetimes
    @datetimes.select {@check_date_in_range_predicate}
  end

  def get_first_appropriate_cita_number
    @datetimes.find_index {@check_date_in_range_predicate} + 1
  end

  def choose_first_appropriate_datetime
    if has_appropriate_datetime?
      n = get_first_appropriate_cita_number
      @session.find(:xpath, 
        '//input[@type="radio" and @title="Seleccionar CITA'.
        concat(" #{n}\"]")).click
    else 
      raise "No appropriate datetimes to choose!"
    end
  end
end