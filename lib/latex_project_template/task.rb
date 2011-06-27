require 'rake'
require 'rake/tasklib'
require 'filename'

class LaTeXProjectTemplate
  class Cleaning
    include Rake::DSL

    attr_reader :temporary, :product, :pattern

    DEFAULT_PATTERN = ["**/*~", "**/*.bak"]

    def initialize
      @pattern = Rake::FileList.new(DEFAULT_PATTERN)
    end

    def clean_files(list)
      list.each do |fn|
        begin
          rm_r fn
        rescue
          nil
        end
      end
    end
    private :clean_files

    def clean
      clean_files(@pattern)
    end
  end

  class Latexmk
    include Rake::DSL

    attr_accessor :path

    def initialize()
      @path = 'latexmk'
      @command = {}

      set(:dvi) do |target|
        "#{@latexmk} -dvi #{target}"
      end
      set(:ps) do |target|
        "#{@latexmk} -ps #{target}"
      end
      set(:pdf) do |target|
        "#{@latexmk} -pdf #{target}"
      end
      set(:clean) do |target|
        "#{@latexmk} -c"
      end
      set(:distclean) do |target|
        "#{@latexmk} -C"
      end
    end

    def set(sym, &block)
      @command[sym] = block
    end

    def command(sym, target)
      @command[sym] && @command[sym].call(target)
    end

    def execute_command(sym, target)
      if c = command(sym, target)
        sh(c)
      end
    end

    [:dvi, :ps, :pdf, :clean, :distclean].each do |sym|
      define_method(sym) do |target|
        execute_command(sym, target)
      end
    end
  end

  class Task < Rake::TaskLib
    attr_accessor :latexmk, :clean

    def initialize(target, &block)
      @target = target
      @latexmk = Latexmk.new
      @clean = Cleaning.new
      yield(self) if block_given?
      define_task
    end

    def define_task
      desc "Clean up temporary files."
      task :clean do |t|
        @latexmk.clean(@target)
        @clean.clean
      end

      desc "Clean up all files."
      task :distclean do |t|
        @latexmk.distclean(@target)
        @clean.clean
      end

      desc "Create dvi."
      task :dvi => [@target] do |t|
        @latexmk.dvi(@target)
      end

      desc "Create ps."
      task :ps => [@target] do |t|
        @latexmk.ps(@target)
      end

      desc "Create pdf."
      task :pdf => [@target] do |t|
        @latexmk.pdf(@target)
      end
    end
  end
end
