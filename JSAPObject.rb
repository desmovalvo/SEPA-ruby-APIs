#!/usr/bin/ruby
# -*- coding: utf-8 -*-

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


  # read update
  def getUpdate(updateName, forcedBindings)
    
    # debug
    @logger.debug("JSAPObject::getUpdate invoked")
    
    # read from the JSAP
    begin
      
      # fetching the dict
      updateDict = @jsap["updates"][updateName]     
        
      # perform the substitution
      updateText = self.getFinalSparql(updateDict, forcedBindings)

      # final value
      @logger.debug("Final version of #{updateName}:")
      @logger.debug(updateText)

    rescue JSON::JSONError
      @logger.error("Update not found")
    end

    # return
    return updateText
  end


  # read query
  def getQuery(queryName, forcedBindings)
    
    # debug
    @logger.debug("JSAPObject::getQuery invoked")
    
    # read from the JSAP
    begin
      
      # fetching the dict
      queryDict = @jsap["queries"][queryName]     
        
      # perform the substitution
      queryText = self.getFinalSparql(queryDict, forcedBindings)

      # final value
      @logger.debug("Final version of #{queryName}:")
      @logger.debug(queryText)

    rescue JSON::JSONError
      @logger.error("Query not found")
    end

    # return
    return queryText
  end


  # read SPARQL
  def getFinalSparql(sparqlDict, forcedBindings)

    # retrieving the sparql
    sparqlText = sparqlDict["sparql"]
    @logger.debug("Retrieved the following template:")
    @logger.debug(sparqlText)

    # replacing forced bindings
    if sparqlDict.key?("forcedBindings")
      sparqlDict["forcedBindings"].each do |varName,varType|
        if forcedBindings.key?(varName)
          
          # build three regular expressions
          rsList = []
          rsList << '(\?|\$){1}' + varName + '\s+'
          rsList << '(\?|\$){1}' + varName + '\}'
          rsList << '(\?|\$){1}' + varName + '\.'
          
          # cycle over regexps and do the substitution
          rsList.each do |rs|
            r = Regexp.new rs  
            sparqlText = sparqlText.gsub(r, " #{forcedBindings[varName]} ")
          end         
        end
      end
    end
    
    # return
    return sparqlText
  end

end
