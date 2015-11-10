require_relative '../datetime_manager_of_available_citas'

RSpec.describe DatetimeManagerOfAvailableCitas, '#has_appropriate_datetime?' do
  before do
  	  @session_double = double("session")
  	  @client_date_start = DateTime.new(2015,11,11)
      @client_date_finish = DateTime.new(2016,11,11)
      @dm = DatetimeManagerOfAvailableCitas.new(@session_double, @client_date_start, @client_date_finish)
  end

  context 'when dates of citas are outdated' do
  	before do
  	  @old_dates = [DateTime.new(2014,1,1), DateTime.new(2013,1,1)]
  	  allow(@dm).to receive(:get_available_datetimes_from_session).
      	and_return @old_dates
      allow(@dm).to receive(:datetimes).and_return(@old_dates)
  	end

    it 'returns false' do
      expect(@dm.has_appropriate_datetime?).to eq false
    end
  end

  context 'when dates of citas are modern' do
  	before do
  	  @dates = [DateTime.new(2015,12,1), DateTime.new(2015,12,2)]
  	  allow(@dm).to receive(:get_available_datetimes_from_session).
      	and_return @dates
      allow(@dm).to receive(:datetimes).and_return(@dates)
  	end

    it 'returns true' do
      expect(@dm.has_appropriate_datetime?).to eq true
    end
  end

end
