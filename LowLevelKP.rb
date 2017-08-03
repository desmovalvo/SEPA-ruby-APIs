#!/usr/bin/ruby

# global reqs
require 'uri'
require 'json'
require 'logger'
require 'net/http'
require 'websocket-client-simple'

# local reqs

# the main class
class LowLevelKP

  # getters
  attr_reader :updateURI, :queryURI, :subscribeURI
  attr_reader :secureUpdateURI, :secureQueryURI, :secureSubscribeURI
  attr_reader :registrationURI, :tokenRequestURI
  attr_accessor :secure
  attr_reader :logLevel
  attr_reader :subscriptions

  # constructor
  def initialize(updateURI, queryURI, subscribeURI, secureUpdateURI, secureQueryURI, secureSubscribeURI, registrationURI, tokenRequestURI, secure, logLevel=Logger::DEBUG)
 
    # initialize a logger
    @logLevel = logLevel
    @logger = Logger.new(STDOUT)
    @logger.level = logLevel
    @logger.debug("LowLevelKP::initialize invoked")

    # store URIs
    @updateURI = updateURI
    @queryURI = queryURI
    @subscribeURI = subscribeURI
    @secureUpdateURI = secureUpdateURI
    @secureQueryURI = secureQueryURI
    @secureSubscribeURI = secureSubscribeURI
    @registrationURI = registrationURI
    @tokenRequestURI = tokenRequestURI

    # initialize a dictionary for subscriptions 
    # (keys are subscriptions aliases)
    @subscriptions = Hash.new

    # store security data
    # TODO -- to be completed
    @secure = secure

  end


  # update
  def update(sparql)

    # debug
    @logger.debug("LowLevelKP::update invoked")

    # secure query?
    if self.secure
      @logger.error("Secure update yet to be implemented")      
    else
      
      # parse uri
      @logger.debug("Issuing update to #{self.updateURI}")
      uri = URI.parse(self.updateURI)

      # build an http request
      req = Net::HTTP::Post.new(uri.request_uri)
      req.content_type = "application/sparql-update"
      req.add_field("Accept", "application/json")
      req.body = sparql
      
      # send data
      http = Net::HTTP.start(uri.host, uri.port)
      res = http.request(req)
      
      # read results
      @logger.debug(res)
      if res.is_a?(Net::HTTPSuccess)
        @logger.debug("Request successful")
      else
        @logger.error(res.body)
        raise res.body
      end
    end    

    # return results
    return res.body

  end


  # query
  def query(sparql)

    # debug
    @logger.debug("LowLevelKP::query invoked")

    # secure query?
    if self.secure
      @logger.error("Secure query yet to be implemented")      
    else
      
      # parse uri
      @logger.debug("Issuing query to #{self.queryURI}")
      uri = URI.parse(self.queryURI)

      # build an http request
      req = Net::HTTP::Post.new(uri.request_uri)
      req.content_type = "application/sparql-query"
      req.add_field("Accept", "application/json")
      req.body = sparql
      
      # send data
      http = Net::HTTP.start(uri.host, uri.port)
      res = http.request(req)
      
      # read results
      @logger.debug(res)
      if res.is_a?(Net::HTTPSuccess)
        @logger.debug("Request successful")
      else
        @logger.error(res.body)
        raise res.body
      end
    end    

    # return results
    return res.body

  end


  # subscribe
  def subscribe(sparql, subAlias, handler)

    # debug
    @logger.debug("LowLevelKP::subscribe invoked")
    @logger.debug(self.subscribeURI)
    @counter = 0

    # initialize return status
    retStatus = nil

    # check if subAlias is already used
    if @subscriptions.key?(subAlias)
      raise NameError, "Alias already used"
    end

    # create a websocket
    ws = WebSocket::Client::Simple.connect(self.subscribeURI, options={"kp" => self, "handler" => handler })
    
    # on open
    ws.on :open do
      
      # initialize a logger
      @logger = Logger.new(STDOUT)
      @logger.level = options["kp"].logLevel
      
      # send the subscription request
      req = {"subscribe" => sparql, "alias" => subAlias}
      ws.send(req.to_json)
      
      # debug print
      @logger.debug("Websocket opened")

    end

    # on message
    ws.on :message do |msg|

      # debug 
      @logger.debug("Received message:")

      # check the content
      begin
        msgDict = JSON.parse(msg.data)
      rescue JSON::ParserError
        logger.error("Error while parsing #{msg}")
      end
      @logger.debug(msgDict.keys)
      
      if msgDict.key?("ping")
        @logger.debug("Ping")

      elsif msgDict.key?("subscribed")
        
        subid = msgDict["subscribed"]
        subalias = msgDict["alias"]
        @logger.debug("Received subscription ID #{subid}")        
        options["kp"].subscriptions[subAlias] = {"ws" => ws, "subid" => subid}
        
        # set the return status
        retStatus = true

      else

        # debug print
        @logger.debug("Notification:")
        @logger.debug(msg.data)

      end

    end
      
    # when closing the websocket do..
    ws.on :close do |e|

      # debug print
      @logger.debug("Websocket closed")

    end

    # on errors do..
    ws.on :error do |e|

      # debug print
      @logger.debug("Websocket error")
      @logger.debug(e)

      # set return status
      retStatus = false

    end    

    # wait for a retStatus
    while retStatus.nil?
    end

    # finally return
    if retStatus
      return @subscriptions[subAlias]["subid"]
    else
      return false
    end

  end


  # unsubscribe
  def unsubscribe(subAlias)

    # debug
    @logger.debug("LowLevelKP::unsubscribe invoked")

    # find the subscription and close it
    @subscriptions[subAlias]["ws"].close()

  end

end
