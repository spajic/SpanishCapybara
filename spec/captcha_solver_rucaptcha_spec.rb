require_relative '../captcha_solver_rucaptcha'

RSpec.describe CaptchaSolverRucaptcha do
  before do
    @solver = CaptchaSolverRucaptcha.new
  end

  describe '#solve' do
    it 'solves test image #1 correctly' do
      expect(@solver.solve('spec/captchas/captcha_test_1.jpg')).to eq 'BCAXBE'
    end
  end
end
