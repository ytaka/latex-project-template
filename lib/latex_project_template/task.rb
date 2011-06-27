require 'rake'
require 'filename'

class LaTeXProjectTemplate
  class Cleaning
    attr_reader :temporary, :product, :pattern

    DEFAULT_PATTERN = ["**/*~", "**/*.bak"]
    DEFAULT_TEMPORARY = ['log', 'aux', 'blg']
    DEFAULT_PRODUCT = ['dvi', 'pdf', 'ps']

    def initialize
      @pattern = Rake::FileList.new(DEFAULT_PATTERN)
      @temporary = DEFAULT_TEMPORARY.dup
      @product = DEFAULT_PRODUCT.dup
    end

    def clean_files(list)
      list.each do |fn|
        rm_r fn
      rescue
        nil
      end
    end
    private :clean_files

    def clean_target_files(target, list_extension)
      list = list_extension.map do |ext|
        FileName.create(target, :extension => ext, :add => :prohibit)
      end
      clean_files(list)
    end
    private :clean_target_files

    def clean(target)
      clean_files(@pattern)
      clean_target_files(target, @temporary)
    end

    def clean_completely(target)
      clean
      clean_target_files(target, @product)
    end
  end

  class Latexmk
    def initialize(latekmk = 'latexmk')
      @latexmk = latexmk
      @clean = Cleaning.new
      @path = {}
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

    [:dvi, :ps, :pdf].each do |sym|
      define_method(sym) do |target|
        execute_command(sym, target)
      end
    end

    def clean(target)
      execute_command(:clean, target)
      @clean.clean(target)
    end

    def distclean(target)
      execute_command(:distclean, target)
      @clean.clean_completely(target)
    end
  end

  class Task < Rake::TaskLib
    attr_accessor :command

    def initialize(target, &block)
      @target = target
      @command = Command::Latexmk.new
      yield(self) if block_given?
      define_task
    end

    def define_task
      desc "Clean up temporary files."
      task :clean do |t|
        @command.clean(@target)
      end

      desc "Clean up all files."
      task :distclean do |t|
        @command.distclean(@target)
      end

      desc "Create dvi."
      task :dvi => [@target] do |t|
        @command.dvi(@target)
      end

      desc "Create ps."
      task :ps => [@target] do |t|
        @command.ps(@target)
      end

      desc "Create pdf."
      task :pdf => [@target] do |t|
        @command.pdf(@target)
      end
    end
  end
end
