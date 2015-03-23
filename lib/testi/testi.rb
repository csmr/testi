#v0.25 Casimir Pohjanraito

#Example use:
#require "testi/testi.rb"
#testi "testing if test works?" { true  }
#testi "Is a integer?" { 1.is_a?(Integer) }
#testitulos
module Testi
  class TestAbort < RuntimeError
  end

  class TestFail < TestAbort
  end

  class TestSkip < TestAbort
  end

	class Stats
		attr_accessor :tests
		attr_accessor :passed
		attr_accessor :failed
		attr_accessor :skipped

		def initialize
			@tests = 0
			@passed = 0
			@failed = 0
			@skipped = 0
		end

		def to_s
			"\n\tStats tot: #{@tests},\tok: #{@passed},\tfail: #{@failed},\tskipped: #{@skipped}\t\tat: #{Time.now}"
		end
	end

	class Context
	  attr_accessor :logger

    def initialize
      @logger = STDERR
      @failed = false
      @skipped = false
    end

    def fail
      @failed = true
    end

    def fail_now
      fail
      raise TestFail
    end

    def failed?
      @failed
    end

    def logf(string, *args)
      @logger.puts sprintf(string, *args) if @logger
    end

    def log(*args)
      logf('%s', *args)
    end

    def fatal(*args)
      log(*args)
      fail_now
    end

    def fatalf(string, *args)
      logf(string, *args)
      fail_now
    end

    def error(*args)
      log(*args)
      fail
    end

    def errorf(string, *args)
      logf(string, *args)
      fail
    end

    def skip_now
      @skipped = true
      raise TestSkip
    end

    def skip(*args)
      log(*args)
      skip_now
    end

    def skipf(string, *args)
      logf(string, *args)
      skip_now
    end

    def skipped?
      @skipped
    end
	end

	class Runner
		attr_reader :stats

		def initialize test_str, stats = nil, &block
			@name = test_str
			@stats = stats || Stats.new
			@block = block
			run
		end

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

	module DSL
		def testi_stats
			@testi_stats ||= Stats.new
		end

		# convenience
		def testi name_str, &block
			Runner.new name_str, testi_stats, &block
		end

		def testi_display_result
			puts testi_stats
		end

		def testi_reset
			testi_stats.clear
		end
	end
end
