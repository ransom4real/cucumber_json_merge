require 'optparse'
require 'find'
require 'fileutils'
require 'json'
require 'deep_merge'

module JsonMerge
  class App
    Error = Class.new(RuntimeError)

    def initialize(options={})
      @stdin  = options[:stdin ] || STDIN
      @stdout = options[:stdout] || STDOUT
      @stderr = options[:stderr] || STDERR
    end

    attr_reader :stdin, :stdout, :stderr

    def run(*args)
      *source_paths, target_path = parse_args(args)
      all_paths = [*source_paths, target_path]

      not_found = all_paths.select { |path| !File.exist?(path) }
      not_found.empty? or
        raise Error, "no such file(s): #{not_found.join(', ')}"

      if source_paths.empty?
        stderr.puts "warning: no source files given"
      else
        source_paths.each do |source_path|
          if File.directory?(source_path)
            Find.find(source_path) do |source_file_path|
              next if !File.file?(source_file_path)
              target_file_path = source_file_path.sub(source_path, target_path)
              if File.exist?(target_file_path)
                merge_file(source_file_path, target_file_path)
              elsif !@update_only
                FileUtils.mkdir_p(File.dirname(target_file_path))
                FileUtils.cp(source_file_path, target_file_path)
              end
            end
          else File.exist?(source_path)
            merge_file(source_path, target_path)
          end
        end
      end
      0
    rescue Error, OptionParser::ParseError => error
      stderr.puts error.message
      1
    end

    private

    def merge_file(source_path, target_path)
      source_text = File.read(source_path).encode!('UTF-8', invalid: :replace)
      target_text = File.read(target_path).encode!('UTF-8', invalid: :replace)

      if target_text =~ /\A\s*\z/m
        return
      end

      if source_text =~ /\A\s*\z/m
        FileUtils.cp source_path, target_path
        return
      end

      source = JSON.parse(source_text)
      target = JSON.parse(target_text)

      target.deep_merge!(source)

      open(target_path, 'w') { |f| f.write(target.to_s) }
    end

    def parse_args(args)
      parser = OptionParser.new do |parser|
        parser.banner = "USAGE: #$0 [options] SOURCES ... TARGET"
      end

      parser.parse!(args)

      args.size >= 1 or
        raise Error, parser.banner

      args
    end
  end
end
