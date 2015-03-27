#v0.25 Casimir Pohjanraito
module Testi
  # TestAbort is a base error for other test related errors
  class TestAbort < RuntimeError
  end

  # TestFail is raised when a Context has called fail_now
  class TestFail < TestAbort
  end

  # TestSkip is raised when a Context has called skip_now
  class TestSkip < TestAbort
  end

  # A class for holding test stats
	class Stats
		attr_accessor :tests
		attr_accessor :passed
		attr_accessor :failed
		attr_accessor :skipped

		def initialize
			clear
		end

    def clear
      @tests = 0
      @passed = 0
      @failed = 0
      @skipped = 0
    end

		def to_s
			"\n\tStats tot: #{@tests},\tok: #{@passed},\tfail: #{@failed},\tskipped: #{@skipped}\t\tat: #{Time.now}"
		end
	end

  # Based on Golang test.T
	class Context
    # @return [#puts]
	  attr_accessor :logger

    def initialize
      @logger = STDERR
      @failed = false
      @skipped = false
    end

    # Marks the context as failed, use #fail_now if you which to terminate the
    # context execution as well.
    def fail
      @failed = true
    end

    # Marks the context as failed and raises a TestFail error
    def fail_now
      fail
      raise TestFail
    end

    # Did the test fail?
    def failed?
      @failed
    end

    # Prints the error to the +@logger+ using sprintf to format the string
    #
    # @param [String] string
    # @param [Object] args
    def logf(string, *args)
      @logger.puts sprintf(string, *args) if @logger
    end

    # Logs result using logf
    #
    # @param [Object] args
    def log(*args)
      logf('%s', *args)
    end

    # Prints args using log and immediately fails the context
    #
    # @param [Object] args
    def fatal(*args)
      log(*args)
      fail_now
    end

    # Prints args using logf and immediately fails the context
    #
    # @param [String] string
    # @param [Object] args
    def fatalf(string, *args)
      logf(string, *args)
      fail_now
    end

    # Prints args using log and marks the context as failed, the test will continue
    #
    # @param [Object] args
    def error(*args)
      log(*args)
      fail
    end

    # Logs args using logf and marks the context as failed, the test will continue
    #
    # @param [String] string
    # @param [Object] args
    def errorf(string, *args)
      logf(string, *args)
      fail
    end

    # Immediately skip the test
    def skip_now
      @skipped = true
      raise TestSkip
    end

    # Logs args using log and skips the test
    #
    # @param [Object] args
    def skip(*args)
      log(*args)
      skip_now
    end

    # Logs args using logf and skips the test
    #
    # @param [String] string
    # @param [Object] args
    def skipf(string, *args)
      logf(string, *args)
      skip_now
    end

    # Was the test skipped?
    def skipped?
      @skipped
    end
	end

	class Runner
		attr_reader :stats

		def initialize(name, stats = nil, &block)
			@name = name
			@stats = stats || Stats.new
			@block = block
			run
		end

    # Executes the test block in a Context, any errors (except TestAbort)
    # that are produced by the test block will be caught and printed.
		def run
		  @stats.tests += 1
			puts "Testi: #{@name}"
			ctx = Context.new
			begin
				ctx.instance_eval(&@block)
			rescue TestAbort # we don't really care if it aborts.
			rescue Exception => ex
				ctx.fail
				@stats.failed += 1
				puts ex.inspect
				puts ex.backtrace.join("\n")
			end
			if ctx.failed?
				puts "  # FAIL!!! ############"
				@stats.failed += 1
			elsif ctx.skipped?
				puts "  = skipped ============"
				@stats.skipped += 1
			else
				puts "  - ok."
				@stats.passed += 1
			end
			puts
		end
	end

  # Domain Specific Language, include this module in your class or main file
  # to use the testi framework, or just require 'testi' instead of 'testi/testi'
	module DSL
    # Test stats.
    # @return [Stats]
		def testi_stats
			@testi_stats ||= Stats.new
		end

    # Runs a new test
    # @param [String] name
		# @example Simple usage example
    #  require 'testi'
    #  testi "testing if test works?" { true  }
    #  testi "Is a integer?" { 1.is_a?(Integer) }
    #  testi_display_result
		def testi(name, &block)
			Runner.new(name, testi_stats, &block)
		end

    # Display the current stats.
		def testi_display_result
			puts testi_stats
		end

    # Reset stats
		def testi_reset
			testi_stats.clear
		end
	end
end
