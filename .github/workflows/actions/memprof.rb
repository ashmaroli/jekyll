# frozen_string_literal: true

require 'jekyll'
require 'memory_profiler'

reporter = MemoryProfiler.report(allow_files: ['lib/jekyll/', 'lib/jekyll.rb']) do
  Jekyll::PluginManager.require_from_bundler
  Jekyll::Commands::Build.process({
    "source"             => File.expand_path(ARGV[0]),
    "destination"        => File.expand_path("#{ARGV[0]}/_site"),
    "disable_disk_cache" => true,
    "quiet"              => true,
  })
  puts ''
end

reporter.instance_variable_set(:@colorize, MemoryProfiler::Monochrome.new)

total_allocated_output = reporter.scale_bytes(reporter.total_allocated_memsize)
total_retained_output  = reporter.scale_bytes(reporter.total_retained_memsize)

puts <<~HTML
  <pre>
  Total allocated: #{total_allocated_output} (#{reporter.total_allocated} objects)
  Total retained:  #{total_retained_output} (#{reporter.total_retained} objects)
  </pre>
  <p>
    <details>
      <summary>Full Report</summary>
      <pre>
#{reporter.print_string_reports($stdout, {scale_bytes: true, normalize_paths: true})}
      </pre>
    </details>
  </p>
HTML
