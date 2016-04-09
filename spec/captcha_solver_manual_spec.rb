require_relative '../captcha_solver_manual'

RSpec.describe CaptchaSolverManual do
  before do
    @solver = CaptchaSolverManual.new
  end

  describe '#solve' do
    it 'solves test image #1 correctly' do
      allow(@solver).to receive :ask_hand_input
      allow(@solver).to receive(:read_hand_input).and_return('BCAXBE')
      expect(@solver.solve('spec/captchas/captcha_test_1.jpg')).to eq 'BCAXBE'
    end

    # Skip because requires hand input of captcha value.
    skip 'solves captcha in manual mode' do
      expect(@solver.solve('spec/captchas/captcha_test_1.jpg')).to eq 'BCAXBE'
    end
  end
end
