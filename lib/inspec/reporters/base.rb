module Inspec::Reporters
  class Base
    attr_reader :run_data

    def initialize(run_data)
      @run_data = run_data
      @output = ''
    end

    def output(str)
      @output << "#{str}\n"
    end

    # each reporter must implement #render
    def render
      raise NotImplementedError, "#{self.class} must implement a `#render` method to format its output."
    end

    def all_unique_controls
      return @unique_controls unless @unique_controls.nil?

      @unique_controls = Set.new
      run_data[:profiles].each do |profile|
        profile[:controls].map { |control| @unique_controls.add(control) }
      end

      @unique_controls
    end

    def profile_summary
      return @profile_summary unless @profile_summary.nil?

      failed = 0
      skipped = 0
      passed = 0
      critical = 0
      major = 0
      minor = 0

      all_unique_controls.each do |control|
        next if control[:id].start_with? '(generated from '
        next unless control[:results]
        if control[:results].any? { |r| r[:status] == 'failed' }
          failed += 1
          if control[:impact] >= 0.7
            critical += 1
          elsif control[:impact] >= 0.4
            major += 1
          else
            minor += 1
          end
        elsif control[:results].any? { |r| r[:status] == 'skipped' }
          skipped += 1
        else
          passed += 1
        end
      end

      total = failed + passed + skipped

      @profile_summary = {
        'total' => total,
        'failed' => {
          'total' => failed,
          'critical' => critical,
          'major' => major,
          'minor' => minor,
        },
        'skipped' => skipped,
        'passed' => passed,
      }
    end

    def tests_summary
      return @tests_summary unless @tests_summary.nil?

      total = 0
      failed = 0
      skipped = 0
      passed = 0

      all_unique_controls.each do |control|
        next unless control[:results]
        control[:results].each do |result|
          if result[:status] == 'failed'
            failed += 1
          elsif result[:status] == 'skipped'
            skipped += 1
          else
            passed += 1
          end
        end
      end

      @test_summary = { 'total' => total, 'failed' => failed, 'skipped' => skipped, 'passed' => passed }
    end
  end
end
