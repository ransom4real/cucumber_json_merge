# frozen_string_literal: true
require 'optparse'
require 'find'
require 'fileutils'
require 'json'
require 'deep_merge'

module CucumberJsonMerge
  # The Cucumber Json Merge app class that handles std inputs and command line args
  class App
    Error = Class.new(RuntimeError)

    def initialize(options = {})
      @stdin  = options[:stdin] || STDIN
      @stdout = options[:stdout] || STDOUT
      @stderr = options[:stderr] || STDERR
    end

    attr_reader :stdin, :stdout, :stderr

    def run(*args)
      *source_paths, target_path = parse_args(args)
      all_paths = [*source_paths, target_path]

      not_found = all_paths.select { |path| !File.exist?(path) }
      raise Error, "no such file(s): #{not_found.join(', ')}" unless
      not_found.empty?

      if source_paths.empty?
        stderr.puts 'warning: no source files given'
      else
        source_paths.each do |source_path|
          if File.directory?(source_path)
            Find.find(source_path) do |source_file_path|
              next unless File.file?(source_file_path)
              target_file_path = source_file_path.sub(source_path, target_path)
              if File.exist?(target_file_path)
                merge_file(source_file_path, target_file_path)
              elsif !@update_only
                FileUtils.mkdir_p(File.dirname(target_file_path))
                FileUtils.cp(source_file_path, target_file_path)
              end
            end
          elsif File.exist?(source_path)
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

      return if target_text =~ /\A\s*\z/m

      if source_text =~ /\A\s*\z/m
        FileUtils.cp source_path, target_path
        return
      end

      source = JSON.parse(source_text)
      target = JSON.parse(target_text)

      source.each do |source_feature|
        target_feature_match = false
        target.each do |target_feature|
          next unless target_feature['name'] == source_feature['name']
          target_feature_match = true
          source_feature['elements'].each do |source_scenario|
            target_scenario_match = false
            target_feature['elements'].each_with_index do |target_scenario, s_index|
              next unless target_scenario['keyword'] == source_scenario[
                'keyword'] && target_scenario['name'] == source_scenario[
                  'name']
              target_scenario_match = true
              target_feature['elements'][s_index] = source_scenario
            end
            target_feature['elements'].push(source_scenario) unless target_scenario_match
          end
        end
        unless target_feature_match
          source_feature['id'] = target.size + 1
          target.push(source_feature)
        end
      end

      open(target_path, 'w') { |f| f.write(target.to_json) }
    end

    def parse_args(args)
      parser = OptionParser.new do |p|
        p.banner = "USAGE: #{$PROGRAM_NAME} [options] SOURCES ... TARGET"
      end

      parser.parse!(args)

      raise Error, parser.banner unless args.size >= 1

      args
    end
  end
end
