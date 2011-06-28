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
      @pattern.clear_exclude
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
    PRODUCT_FILE_TYPE = [:dvi, :ps, :pdf]

    include Rake::DSL

    attr_accessor :path

    def initialize()
      @path = 'latexmk'
      @command = {}

      set(:dvi) do |target|
        "#{@path} -dvi #{target}"
      end
      set(:ps) do |target|
        "#{@path} -ps #{target}"
      end
      set(:pdf) do |target|
        "#{@path} -pdf #{target}"
      end
      set(:clean) do |target|
        "#{@path} -c"
      end
      set(:distclean) do |target|
        "#{@path} -C"
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

    (PRODUCT_FILE_TYPE + [:clean, :distclean]).each do |sym|
      define_method(sym) do |target|
        execute_command(sym, target)
      end
    end
  end

  class Task < Rake::TaskLib
    attr_accessor :latexmk, :clean, :default

    def initialize(target, &block)
      @target = target
      @latexmk = Latexmk.new
      @clean = Cleaning.new
      @default = :pdf
      yield(self) if block_given?
      define_task
    end

    def snapshot_of_current(type)
      path = FileName.create(@target, :add => :prohibit, :extension => ".#{type}")
      snapshot_path = FileName.create("snapshot", File.basename(path),
                                      :type => :time, :directory => :parent, :position => :middle,
                                      :delimiter => '', :add => :always, :format => "%Y%m%d_%H%M%S")
      begin
        Rake::Task[type].execute
      rescue
        $stderr.puts "Can not compile"
      end
      if File.exist?(path)
        move(path, snapshot_path)
      end
    end
    private :snapshot_of_current

    def snapshot_of_commit(type, commit)
      source_directory = FileName.create('src', :type => :time, :directory => :self, :add => :always)
      path = FileName.create(source_directory, File.basename(@target), :add => :prohibit, :extension => ".#{type}")
      snapshot_path = FileName.create("snapshot", File.basename(path),
                                      :type => :time, :directory => :parent, :position => :middle,
                                      :delimiter => '', :add => :always, :format => "%Y%m%d_%H%M%S")
      c = "git archive --format=tar #{commit} | tar -C #{source_directory} -xf -"
      system(c)
      cd source_directory
      begin
        sh "rake #{type}"
      rescue
        $stderr.puts "Can not compile: #{source_directory}"
      end
      if File.exist?(path)
        move(path, snapshot_path)
        cd '..'
        rm_r source_directory
      end
    end
    private :snapshot_of_commit

    def define_task
      desc "Default task"
      task :default => @default

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

      desc "Create snapshot file."
      task :snapshot, [:type,:commit] do |t, args|
        type = args.type && args.type.size > 0 ? args.type.intern : :pdf
        unless Latexmk::PRODUCT_FILE_TYPE.include?(type)
          raise "Invalid type of file: #{type}."
        end
        if commit = args.commit
          snapshot_of_commit(type, commit)
        else
          snapshot_of_current(type)
        end
      end
    end
  end
end
