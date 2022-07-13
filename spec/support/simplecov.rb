# frozen_string_literal: true

require 'simplecov'

SimpleCov.start do
  # exclude specs
  add_filter %r{^/spec/}
  # exclude gem related files
  add_filter %w{namespace.rb}

  add_group "Base" do |file|
    file.filename.match(/namespace\/[\w_]+\.rb/)
  end

  add_group "Ruby" do |file|
    file.filename.match(/ruby\//)
  end
end