# frozen_string_literal: true

require "jekyll"
require "stackprof"

PROF_OUTPUT_FILE = File.expand_path(".stackprof-cpu.dump", __dir__).freeze

StackProf.run(mode: :object, out: PROF_OUTPUT_FILE) do
  Jekyll::PluginManager.require_from_bundler
  Jekyll::Commands::Build.process({
    "source"             => File.expand_path(ARGV[0]),
    "destination"        => File.expand_path("#{ARGV[0]}/_site"),
    "disable_disk_cache" => true,
  })
  puts ""
end

StackProf::Report.new(Marshal.load(IO.binread(PROF_OUTPUT_FILE))).print_text
