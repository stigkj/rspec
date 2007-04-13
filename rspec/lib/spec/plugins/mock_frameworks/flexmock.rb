#!/usr/bin/env ruby
#
#  Created by Jim Weirich on 2007-04-10.
#  Copyright (c) 2007. All rights reserved.

begin
 require 'rubygems'
rescue LoadError => ex
end
require 'flexmock/rspec'

module Spec
 module Plugins
   module MockMethods
     include FlexMock::MockContainer
     def setup_mocks_for_rspec
       # No setup required
     end
     def teardown_mocks_for_rspec
       begin
         flexmock_verify
       ensure
         flexmock_close
       end
     end
   end
 end
end