require 'spec_helper'

describe Lita::Handlers::OdotTripcheck, lita_handler: true do
  before(:each) do
    registry.configure do |config|
      config.handlers.odot_tripcheck.uri = 'http://www.tripcheck.com/TTIPv2/TTIPData/DataRequest.aspx?uid=[uid]&fn=[xmlfile]'  # Ensure you put [uid] and [xmlfile] in the appropriate spot.
      config.handlers.odot_tripcheck.uid = '1306'
    end
  end

  it { is_expected.to route('!tripcheck') }

  it 'will respond to tripcheck' do
    send_message '!tripcheck'
    expect(replies.last).to eq('x')
  end
end
