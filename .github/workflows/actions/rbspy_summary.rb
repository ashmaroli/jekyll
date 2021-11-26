# frozen_string_literal: true

require 'colorator'
require 'terminal-table'

module Terminal
  class Table
    class AsciiBorder < Border
      def initialize
        super
        @data = { x: "-", y: "", i:  "" }
      end
    end
  end
end

LINE_RE = %r!^ +(\d{1,2}\.\d{2}) {4}(\d{1,2}\.\d{2}) {2}(.+) - (.+)$!
NAME_RE = %r!(/opt/hostedtoolcache/Ruby/2.7.3/x64/lib/ruby/gems/2.7.0/(gems|bin)/|/home/runner/work/jekyll/)!

table = Terminal::Table.new do |t|
  t << ["% self", "% total", "", "name"]
  t << :separator
  File.read(ARGV[0]).scan(LINE_RE) do |stime, total, name, loc|
    t << [stime, total, (name.include?("c function") ? name.cyan : name), loc.gsub(NAME_RE, "")]
  end
  t.style = {
    alignment: :right,
    border: :ascii,
    border_top: false,
    border_left: false,
    border_right: false,
  }
  t.align_column(-1, :left)
end

puts ""
puts table
