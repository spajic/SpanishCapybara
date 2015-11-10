require_relative '../datetime_manager_of_available_citas'

RSpec.describe DatetimeManagerOfAvailableCitas do
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

  	describe '#has_appropriate_datetime?' do
  	  it 'returns false' do
        expect(@dm.has_appropriate_datetime?).to eq false
      end
  	end  

  	describe '#get_appropriate_datetimes' do
  	  it 'returns []' do
        expect(@dm.get_appropriate_datetimes).to eq []
      end
  	end

  	describe '#get_first_appropriate_cita_number' do
  	  it 'returns nil' do
        expect(@dm.get_first_appropriate_cita_number).to eq nil
      end
  	end  
  end

  context 'when dates of citas are modern' do
  	before do
  	  @dates = [DateTime.new(2015,12,1), DateTime.new(2015,12,2)]
  	  allow(@dm).to receive(:get_available_datetimes_from_session).
      	and_return @dates
      allow(@dm).to receive(:datetimes).and_return(@dates)
  	end

    describe '#has_appropriate_datetime?' do
  	  it 'returns true' do
        expect(@dm.has_appropriate_datetime?).to eq true
      end
  	end  

  	describe '#get_appropriate_datetimes' do
  	  it 'returns array of datetimes' do
        expect(@dm.get_appropriate_datetimes).to eq @dates
      end
  	end

  	describe '#get_first_appropriate_cita_number' do
  	  it 'returns 1' do
        expect(@dm.get_first_appropriate_cita_number).to eq 1
      end
  	end
  end

end
