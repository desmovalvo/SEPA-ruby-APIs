#!/usr/bin/ruby

# global reqs
require 'uri'
require 'json'
require 'logger'
require 'net/http'

# local reqs

# the main class
class LowLevelKP

  # getters
  attr_reader :updateURI, :queryURI, :subscribeURI
  attr_reader :secureUpdateURI, :secureQueryURI, :secureSubscribeURI
  attr_reader :registrationURI, :tokenRequestURI
  attr_accessor :secure


  # constructor
  def initialize(updateURI, queryURI, subscribeURI, secureUpdateURI, secureQueryURI, secureSubscribeURI, registrationURI, tokenRequestURI, secure)
 
    # initialize a logger
    @logger = Logger.new(STDOUT)
    @logger.debug("LowLevelKP::initialize invoked")

    # store URIs
    @updateURI = updateURI
    @queryURI = queryURI
    @subscribeURI = secureUpdateURI
    @secureQueryURI = secureQueryURI
    @secureSubscribeURI = secureSubscribeURI
    @registrationURI = registrationURI
    @tokenRequestURI = tokenRequestURI

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
  def subscribe(sparql, handler)

    # debug
    @logger.debug("LowLevelKP::subscribe invoked")

  end


  # unsubscribe
  def unsubscribe(subid)

    # debug
    @logger.debug("LowLevelKP::unsubscribe invoked")

  end

end
