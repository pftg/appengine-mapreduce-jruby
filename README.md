AppEngine MapReduce JRuby Wrapper
=================================


DESCRIPTION:
------------

APIs and utilities for using AppEngine-MapReduce in JRuby on Google App Engine


INSTALL:
--------

In Gemfile add:
    
    gem 'appengine-mapreduce'


EXAMPLE:
--------

   require 'appengine-mapreduce'

   job = AppEngine::MapReduce::Job.new :input_kind => 'PBVote'  
   job.map do |k, v, context|
     puts "map key: #{key}"
   end


   require 'appengine-mapreduce'

   class Entry
     include AppEngine::Resource
     include AppEngine::Mappable
   end

   Entry.async_map do |k, v, c|
     puts "map key: #{key}"
   end


REQUIREMENTS TO BUILD:
----------------------

* Google App Engine SDK for Java (http://code.google.com/appengine)
* AppEngine-MapReduce for Java (http://code.google.com/p/appengine-mapreduce)
* Apache Maven (http://maven.apache.org/)


BUILD:
------

1. Checkout and change dir to appengine-mapreduce-jruby

1. Install AppEngine-MapReduce artifact to local Maven repository:
    
        rake check_dependencies

1. Build gem:

        rake build


TODO:
--------

*   Add documantation
*   Add more examples
*   Add more tests

LICENSE:
--------

Copyright 2009-2010 Paul Nikitochkin

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
