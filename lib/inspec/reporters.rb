require 'inspec/reporters/base'
require 'inspec/reporters/cli'
require 'inspec/reporters/json'
require 'inspec/reporters/json_min'
require 'inspec/reporters/junit'

module Inspec::Reporters

  def self.render(report, path, run_data)
    case report
    when 'cli'
      output = Inspec::Reporters::CLI.new(run_data).render
    when 'json'
      output = Inspec::Reporters::Json.new(run_data).render
    when 'json-min'
      output = Inspec::Reporters::JsonMin.new(run_data).render
    when 'junit'
      output = Inspec::Reporters::Junit.new(run_data).render
    end

    if path.nil? or path.strip == '-'
      puts output
    else
      File.write(path, output)
    end
  end
end
