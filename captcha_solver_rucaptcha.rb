require 'rucaptcha_api'

# Solve captcha via rucaptcha service.
class CaptchaSolverRucaptcha
  def initialize
    @api = RucaptchaApi.new ENV['RUCAPTCHA_KEY']
  end

  def solve(path_to_captcha_image_file)
    puts 'REQUEST RUCAPTCHA'
    captcha_id = @api.send_captcha_for_solving(
      File.expand_path(path_to_captcha_image_file),
      params: {
        language: 2, # English
        phrase: 1, # Капча из двух слов
      }
    )
    solved_captcha = @api.get_solved_captcha(captcha_id)
    puts 'RUCAPTHCA REQUEST SUCCESS'
    puts solved_captcha
    puts '*****************************************'
    solved_captcha.upcase
  end
end
