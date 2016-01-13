require 'launchy'

class RuCaptchaSolver
  def initialize

  end
end

class CaptchaSolverByHand
  def solve(path_to_captcha_image_file)
    show_capthca(path_to_captcha_image_file)
    get_hand_input
  end

  private
    def show_capthca(path_to_captcha_image_file)
      Launchy.open(path_to_captcha_image_file)
    end

    def get_hand_input
      puts "Enter Capthca value, please: "
      res = gets
      res.chomp!
    end
end
