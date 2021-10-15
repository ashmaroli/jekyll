#!/usr/bin/env ruby
# frozen_string_literal: true

require "benchmark/ips"
require "jekyll"

CONTEXT = { "bar" => "The quick brown fox" }
MARKUP_1 = %Q(snippet.html foo=bar lorem="ipsum \\"dolor\\"" alpha='beta \\'gamma\\'').freeze
MARKUP_2 = %Q(snippet.html foo=bar lorem="ipsum 'dolor'" alpha='beta "gamma"').freeze
MARKUP_3 = %Q({{ file }} foo=bar lorem="ipsum \\"dolor\\"" alpha='beta \\'gamma\\'').freeze
MARKUP_4 = %Q({{ file }} foo=bar lorem="ipsum 'dolor'" alpha='beta "gamma"').freeze

class Base
  PARAMS_PATTERN = Jekyll::Tags::IncludeTag::VALID_SYNTAX
  VARIABLE_FILE  = Jekyll::Tags::IncludeTag::VARIABLE_SYNTAX

  def render
    1000.times do
      extract_params_hash
    end
  end

  def extract_params_hash; end
end

class LegacyInclude < Base
  def initialize(markup)
    matched = markup.strip.match(VARIABLE_FILE)
    if matched
      @file = matched["variable"].strip
      @params = matched["params"].strip
    else
      @file, @params = markup.strip.split(%r!\s+!, 2)
    end
  end

  def extract_params_hash
    params = {}
    markup = @params

    while (match = PARAMS_PATTERN.match(markup))
      markup = markup[match.end(0)..-1]

      value = if match[2]
                match[2].gsub('\\"', '"')
              elsif match[3]
                match[3].gsub("\\'", "'")
              elsif match[4]
                CONTEXT[match[4]]
              end

      params[match[1]] = value
    end
    params
  end
end

class OptimizedInclude < Base
  def initialize(markup)
    markup  = markup.strip
    matched = markup.match(VARIABLE_FILE)
    if matched
      @file = matched["variable"].strip
      @params = matched["params"].strip
    else
      @file, @params = markup.split(%r!\s+!, 2)
    end
  end

  def extract_params_hash
    params = {}
    @params.scan(PARAMS_PATTERN) do |key, d_quoted, s_quoted, variable|
      value = if d_quoted
                d_quoted.include?('\\"') ? d_quoted.gsub('\\"', '"') : d_quoted
              elsif s_quoted
                s_quoted.include?("\\'") ? s_quoted.gsub("\\'", "'") : s_quoted
              elsif variable
                CONTEXT[variable]
              end

      params[key] = value
    end
    params
  end
end

class SuperOptimizedInclude < Base
  def initialize(markup)
    markup  = markup.strip
    matched = markup.match(VARIABLE_FILE)
    if matched
      @file = matched["variable"].strip
      @params = matched["params"].strip
    else
      @file, @params = markup.split(%r!\s+!, 2)
    end
    return unless @params

    @params = nil if @params.empty?
    tokenize_params if @params
  end

  def tokenize_params
    @param_tokens = @params.scan(PARAMS_PATTERN).map! do |key, d_quoted, s_quoted, variable|
      [
        key,
        (d_quoted&.include?('\\"') ? d_quoted.gsub('\\"', '"') : d_quoted),
        (s_quoted&.include?("\\'") ? s_quoted.gsub("\\'", "'") : s_quoted),
        variable,
      ]
    end
  end

  def extract_params_hash
    params = {}
    @param_tokens.each do |key, d_quoted, s_quoted, variable|
      value = if d_quoted
                d_quoted
              elsif s_quoted
                s_quoted
              elsif variable
                CONTEXT[variable]
              end
      params[key] = value
    end
    params
  end
end

[MARKUP_1, MARKUP_2, MARKUP_3, MARKUP_4].each do |markup|
  puts " MARKUP: #{markup}"
  puts <<~TEXT
    RESULTS:
               LEGACY: #{LegacyInclude.new(markup).extract_params_hash}
            OPTIMIZED: #{OptimizedInclude.new(markup).extract_params_hash}
      SUPER-OPTIMIZED: #{SuperOptimizedInclude.new(markup).extract_params_hash}
  TEXT
  puts ""

  Benchmark.ips do |x|
    x.report('legacy') { LegacyInclude.new(markup).render }
    x.report('optimized') { OptimizedInclude.new(markup).render }
    x.report('super-optimized') { SuperOptimizedInclude.new(markup).render }
    x.compare!
  end
end

