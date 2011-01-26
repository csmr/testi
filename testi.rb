module Testi

	class TestiRunner
	#v0.25 Casimir Pohjanraito

	#Example use: 
	#require "testi/testi.rb"
	#testi "testing if test works?" { true  }
	#testi "Is a integer?" { 1.is_a?(Integer) }
	#testitulos
	
		@@tests, @@passed,	@@failed = 0, 0, 0

		def initialize(test_str, test_proc)
		  @@tests += 1
			print "Testi: " + test_str + " "
			result = test_proc.call
			if result == true
				print "- ok."
				@@passed += 1
			else
				print "# FAIL!!! ############"
				@@failed += 1
			end
			print "\n" 
		end

		def self.stats
		 	print "Testi tot: #{@@tests},  ok: #{@@passed}, fail: #{@@failed} at " +  Time.now.to_s
		end
		
		def self.reset
			@@tests, @@passed, @@failed = 0, 0, 0
		end
	
	end #Testi class

	#convenience
	def testi(name_str, &block)
		TestiRunner.new(name_str, block)
	end

	def testitulos
		TestiRunner.stats
		true
	end

	def testireset
		TestiRunner.reset
	end


end

extend Testi

