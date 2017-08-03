#!/usr/bin/ruby

# global requirements
require 'logger'

# local requirements
load 'JSAPObject.rb'
load 'LowLevelKP.rb'
 

# initialize a logger
@logger = Logger.new(STDOUT)
@logger.debug("JSAPObject::initialize invoked")

####################################################
##
## JSAP Object
## 
####################################################

# test JSAPObject
@logger.debug("===== Testing JSAPObject class =====")

# open a jsap file
@logger.debug("===== 1 - constructor =====")
j = JSAPObject.new("example.jsap")

# retrieve a query
@logger.debug("===== 2 - retrieve a query =====")
j.getQuery("OBJECTS_OF_CLASS", {"class" => "foaf:Person"})

# retrieve an update
@logger.debug("===== 3 - retrieve an update =====")
j.getUpdate("INSERT_OBJECT_OF_CLASS", {"class" => "foaf:Person", "ob" => "foaf:FakePerson1"})

####################################################
##
## LowLevelKP
## 
####################################################

# test LowLevelKP
@logger.debug("===== Testing LowLevelKP class =====")

# open a jsap file
@logger.debug("===== 1 - constructor =====")
kp = LowLevelKP.new(j.updateURI, j.queryURI, j.subscribeURI,
                    j.secureUpdateURI, j.secureQueryURI, j.secureSubscribeURI,
                    j.registrationURI, j.tokenRequestURI, false)

# perform a query
@logger.debug("===== 2 - query =====")
kp.query(j.getQuery("EVERYTHING", Hash.new))

# perform an update
@logger.debug("===== 3.1 - update =====")
kp.update(j.getUpdate("INSERT_OBJECT_OF_CLASS", {"class" => "foaf:Person", "ob" => "foaf:FabioViola_URI" }))

# perform a query
@logger.debug("===== 3.2 - update =====")
kp.update(j.getUpdate("DELETE_OBJECT_OF_CLASS", {"class" => "foaf:Person", "ob" => "foaf:FabioViola_URI" }))
