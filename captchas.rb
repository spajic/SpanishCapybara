require 'launchy'
require 'rucaptcha_api'

class RuCaptchaSolver
  def initialize
    @api = RucaptchaApi.new ENV['RUCAPTCHA_KEY']
  end

  def solve(path_to_captcha_image_file)
    puts 'REQUEST RUCAPTCHA'
    path_to_captcha = File.expand_path path_to_captcha_image_file
    captcha_id = @api.send_captcha_for_solving(path_to_captcha, params: {language: 2})
    solved_captcha = @api.get_solved_captcha captcha_id
    puts "RUCAPTHCA REQUEST SUCCESS"
    solved_captcha.upcase
  end
end

class CaptchaSolverByHand
  def solve(path_to_captcha_image_file)
    ask_hand_input
    get_hand_input
  end

  private
    def show_capthca(path_to_captcha_image_file)
      Launchy.open(path_to_captcha_image_file)
    end

    def ask_hand_input
      show_capthca(path_to_captcha_image_file)
      puts "Enter Capthca value, please: "
    end

    def get_hand_input
      res = gets
      res.chomp!
    end
end
