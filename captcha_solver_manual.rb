require 'launchy'

# Solve captcha by asking user to recognize and input captcha.
class CaptchaSolverManual
  def solve(path_to_captcha_image_file)
    @path = path_to_captcha_image_file

    ask_hand_input
    read_hand_input
  end

  private

  def show_capthca
    Launchy.open(@path)
  end

  def ask_hand_input
    show_capthca
    puts 'Enter Capthca value, please: '
  end

  def read_hand_input
    res = gets
    res.chomp!
  end
end
