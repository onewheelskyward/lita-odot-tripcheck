require 'httparty'
require 'nokogiri'

module Lita
  module Handlers
    class OdotTripcheck < Handler
      config :uid
      config :uri
#       linkinventory linkstatus.     ODOT Region 1 Vehicle Detection Station (VDS)      Inventory: 24 hours    Status: 2 minutes
#       dmsinventory   dmsstatus      ODOT Region 1 *Dynamic Message Sign (DMS)          Inventory: 24 hours    Status: 2 minutes
#       Dmsinventory-sw Dmsstatus-sw  ODOT State *Statewide Dynamic Message Sign (DMS)   Inventory: 24 hours    Status: 2 minutes
#       rwis.                         ODOT State Road Weather Information System
#                                     (automated weather stations)                                              15 minutes
#       rw                            ODOT State Road Weather(road crew observations)                           15 minutes
#       incd                          ODOT State Event (planned closures, construction)
#                                     Incident (accident, Link (Weight limitations)                             2 minutes
#       incd-tle                      TLE Local (non-ODOT events)                                               2 minutes
#       cctvInventory                 ODOT State Closed Circuit TV                       Inventory: 24 hours
#       not available                 City of Portland Vehicle Detection Station (VDS)                          5 minutes
#       pdxparking                    Port of Portland Parking Lot availability                                 5 minutes

      @@xmlfile_meta = {'linkinventory'   => 2,
                       'linkstatus'      => 2,
                       'dmsinventory'    => 2,
                       'dmsstatus'       => 2,
                       'Dmsinventory-sw' => 2,
                       'Dmsstatus-sw'    => 2,
                       'rwis'            => 15,
                       'rw'              => 15,
                       'incd'            => 2,
                       'incd-tle'        => 2,
                       'cctvInventory'   => 1440,
                       'pdxparking'      => 5}

      route(/^!tripcheck/i, :handle_tripcheck)
      route(/^!roadcam/i, :handle_roadcam)

      def build_uri(xmlfile)
        unless @@xmlfile_meta.keys.include? xmlfile
          raise "#{xmlfile} not found in the allowed xml file choices."
        end

        uri = config.uri
        uri.gsub! '[uid]', config.uid
        uri.gsub! '[xmlfile]', xmlfile
        uri
      end
      
      def api_call(uri)
        puts uri
        # response = HTTParty.get uri
        
      end
      
      def handle_tripcheck(response)
        uri = build_uri 'linkinventory'
        api_call uri
        response.reply uri
      end
      
      def handle_roadcam(response)
        xmlfil = File.open('ccInventory.xml')
        nokodoc = Nokogiri::XML xmlfil
        nokodoc.xpath('//cCTVInventory').each do |node|
          response.reply node.xpath('location/latitude').text.insert -6, '.'
          response.reply node.xpath('location/longitude').text.insert -6, '.'
          response.reply node.xpath('cctv-url').text.strip.gsub ' ', '%20'

          # response.reply node.text.strip.gsub ' ', '+'
        end
        xmlfil.close
      end
    end

    Lita.register_handler(OdotTripcheck)
  end
end
