# frozen_string_literal: true

require_relative "lib/worklog/version"

Gem::Specification.new do |spec|
  spec.name = "worklog"
  spec.version = Worklog::VERSION
  spec.authors = ["Shinpei Noda"]
  spec.summary = "Render Claude Code session history as a calendar"
  spec.required_ruby_version = ">= 3.3"

  spec.files = Dir["lib/**/*.{rb,erb}", "exe/*", "README.md"]
  spec.bindir = "exe"
  spec.executables = ["worklog"]
  spec.require_paths = ["lib"]
end
