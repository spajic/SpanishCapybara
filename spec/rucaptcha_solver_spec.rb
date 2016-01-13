require_relative '../captchas'

RSpec.describe RuCaptchaSolver do
  before do
  	  @s = RuCaptchaSolver.new
  end

  describe '#solve' do
    skip 'solves test image #1 correctly' do
      expect(@s.solve 'spec/captchas/captcha_test_1.jpg').to eq 'BCAXBE'
    end
  end  

end

RSpec.describe CaptchaSolverByHand do
  before do
  	  @s = CaptchaSolverByHand.new
	  allow(@s).to receive :ask_hand_input
	  allow(@s).to receive :thanks_for_hand_input
  end

  describe '#solve' do
    it 'solves test image #1 correctly' do
	  allow(@s).to receive(:get_hand_input).and_return('BCAXBE')
      expect(@s.solve 'spec/captchas/captcha_test_1.jpg').to eq 'BCAXBE'
    end
  end  

end
