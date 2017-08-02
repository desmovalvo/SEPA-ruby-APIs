#!/usr/bin/ruby

# global reqs
require 'json'
require 'logger'

# the main class
class JSAPObject

  # instance variables
  @updateURI = nil
  @queryURI = nil
  @subscribeURI = nil
  @secureUpdateURI = nil
  @secureQueryURI = nil
  @secureSubscribeURI = nil
  @registrationURI = nil
  @tokenRequestURI = nil
  @jsap = nil

  # constructor
  def initialize(jsapFile)
 
    # initialize a logger
    @logger = Logger.new(STDOUT)
    @logger.debug("JSAPObject::initialize invoked")
   
    # try to parse the JSAP file
    begin
      file = File.read(jsapFile)
      @jsap = JSON.parse(file)
      @logger.debug("JSAP File opened correctly")
    rescue JSON::JSONError
      @logger.fatal("Impossible to parse JSAP file")
    end

    # read network addresses
    self.readNetworkURIs()

  end

  # readNetworkURIs
  def readNetworkURIs()

    # debug
   @logger.debug("JSAPObject::readNetworkURIs invoked")
    
    # read from the dict
    begin
    
      # read the host
      host = @jsap["parameters"]["host"]
      
      # read URIs for unsecure operations
      @updateURI = "http://#{host}:#{@jsap["parameters"]["ports"]["http"]}/#{@jsap["parameters"]["paths"]["update"]}"
      @queryURI = "http://#{host}:#{@jsap["parameters"]["ports"]["http"]}/#{@jsap["parameters"]["paths"]["query"]}"
      @subscribeURI = "ws://#{host}:#{@jsap["parameters"]["ports"]["ws"]}/#{@jsap["parameters"]["paths"]["subscribe"]}"
      
      # read URIs for secure operations
      @secureUpdateURI = "https://#{host}:#{@jsap["parameters"]["ports"]["https"]}/#{@jsap["parameters"]["paths"]["securePath"]}/#{@jsap["parameters"]["paths"]["update"]}"
      @secureQueryURI = "https://#{host}:#{@jsap["parameters"]["ports"]["https"]}/#{@jsap["parameters"]["paths"]["securePath"]}/#{@jsap["parameters"]["paths"]["query"]}"
      @secureSubscribeURI = "wss://#{host}:#{@jsap["parameters"]["ports"]["wss"]}/#{@jsap["parameters"]["paths"]["securePath"]}/#{@jsap["parameters"]["paths"]["subscribe"]}"
      
      # read URIs for registration and token requests
      @registrationURI = "https://#{host}:#{@jsap["parameters"]["ports"]["https"]}/#{@jsap["parameters"]["paths"]["register"]}"
      @tokenRequestURI = "https://#{host}:#{@jsap["parameters"]["ports"]["https"]}/#{@jsap["parameters"]["paths"]["tokenRequest"]}"

      # debug
      @logger.debug("Found the following URIs for unsecure connection:")
      @logger.debug(@updateURI)
      @logger.debug(@queryURI)
      @logger.debug(@subscribeURI)
      @logger.debug("Found the following URIs for secure connection:")
      @logger.debug(@secureUpdateURI)
      @logger.debug(@secureQueryURI)
      @logger.debug(@secureSubscribeURI)
      @logger.debug("Found the following URIs for registration and authorization:")
      @logger.debug(@registrationURI)
      @logger.debug(@tokenRequestURI)
      
    rescue JSON::JSONError
      @logger.error("Impossible to read URIs")
    end
    
  end

end
