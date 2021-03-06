# frozen_string_literal: true
class Shoes
  module Swt
    class Packager
      attr_accessor :gems

      def initialize(dsl)
        @dsl  = dsl
        @gems = []
      end

      def create_package(program_name, package)
        unless package =~ /^(swt):(app|jar)$/
          abort("#{program_name}: Can't package as '#{package}'. See '#{program_name} --help'")
        end
        package.split(':')
      end

      def run(path)
        begin
          require 'shoes/package'
          require 'shoes/package/configuration'
          config = ::Shoes::Package::Configuration.load(path)
          config.gems.concat(@gems)
        rescue Errno::ENOENT => e
          abort "shoes: #{e.message}"
        end

        @dsl.packages.each do |backend, wrapper|
          puts "Packaging #{backend}:#{wrapper}..."
          packager = ::Shoes::Package.create_packager(config, wrapper)
          packager.package
        end
      end

      def help(program_name)
        <<-EOS

    Package types:
#{package_types}
    Examples:
#{examples(program_name)}
        EOS
      end

      def package_types
        <<-EOS
    swt:app     A standalone OS X executable with the Swt backend
    swt:jar     An executable JAR with the Swt backend
        EOS
      end

      def examples(program_name)
        <<-EOS
    To run a Shoes app:
      #{program_name} path/to/shoes-app.rb

    Two ways to package a Shoes app as an APP and a JAR, using the Swt backend:
      #{program_name} -p swt:app -p swt:jar path/to/app.yaml
      #{program_name} -p swt:app -p swt:jar path/to/shoes-app.rb
          EOS
      end
    end
  end
end
