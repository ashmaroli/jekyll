# frozen_string_literal: true

require "jekyll"

namespace :profile do
  desc "Profile allocations from a build session"
  task :memory, [:file, :mode] do |_t, args|
    args.with_defaults(file: "memprof.txt", mode: "lite")

    build_phases = [:reset, :read, :generate, :render, :cleanup, :write]
    safe_mode    = false

    if args.mode == "lite"
      build_phases -= [:render, :generate]
      safe_mode     = true
    end

    require "memory_profiler"

    module MemoryProfiler
      class Reporter
        def object_list(generation)
          rvalue_size = GC::INTERNAL_CONSTANTS[:RVALUE_SIZE]
          helper = Helpers.new

          result = StatHash.new.compare_by_identity

          ObjectSpace.each_object do |obj|
            next unless ObjectSpace.allocation_generation(obj) == generation

            file = ObjectSpace.allocation_sourcefile(obj) || "(no name)"
            next if @ignore_files && @ignore_files =~ file
            next if @allow_files && !(@allow_files =~ file)

            klass = obj.class rescue nil
            unless Class === klass
              # attempt to determine the true Class when .class returns something other than a Class
              klass = Kernel.instance_method(:class).bind(obj).call
            end
            next if @trace && !trace.include?(klass)

            begin
              line       = ObjectSpace.allocation_sourceline(obj)
              location   = helper.lookup_location(file, line)
              class_name = helper.lookup_class_name(klass)
              gem        = helper.guess_gem(file)

              # we do memsize first to avoid freezing as a side effect and shifting
              # storage to the new frozen string, this happens on @hash[s] in lookup_string
              memsize = ObjectSpace.memsize_of(obj)

              if klass == Array
                puts location.to_s.cyan
                puts obj.inspect
                puts ""
              end

              string = klass == String ? helper.lookup_string(obj) : nil

              # compensate for API bug
              memsize = rvalue_size if memsize > 100_000_000_000
              result[obj.__id__] = MemoryProfiler::Stat.new(class_name, gem, file, location, memsize, string)
            rescue
              # give up if any any error occurs inspecting the object
            end
          end

          result
        end
      end
    end

    report = MemoryProfiler.report(trace: [Array], allow_files: "jekyll/") do
      site = Jekyll::Site.new(
        Jekyll.configuration(
          "source"      => File.expand_path("../docs", __dir__),
          "destination" => File.expand_path("../docs/_site", __dir__),
          "safe"        => safe_mode
        )
      )

      Jekyll.logger.info "Source:", site.source
      Jekyll.logger.info "Destination:", site.dest
      Jekyll.logger.info "Plugins and Cache:", site.safe ? "disabled" : "enabled"
      Jekyll.logger.info "Profiling phases:", build_phases.join(", ").cyan
      Jekyll.logger.info "Profiling..."

      build_phases.each { |phase| site.send phase }

      Jekyll.logger.info "", "and done. Generating results.."
      Jekyll.logger.info ""
    end

    # if ENV["CI"]
    #   report.pretty_print(scale_bytes: true, color_output: false, normalize_paths: true)
    # else
    #   FileUtils.mkdir_p("tmp")
    #   report_file = File.join("tmp", args.file)

      total_allocated_output = report.scale_bytes(report.total_allocated_memsize)
      total_retained_output  = report.scale_bytes(report.total_retained_memsize)

      Jekyll.logger.info "Total allocated: #{total_allocated_output} (#{report.total_allocated} objects)".cyan
      Jekyll.logger.info "Total retained:  #{total_retained_output} (#{report.total_retained} objects)".cyan

    #   report.pretty_print(to_file: report_file, scale_bytes: true, normalize_paths: true)
    #   Jekyll.logger.info "\nDetailed Report saved into:", report_file.cyan
    # end
  end
end
