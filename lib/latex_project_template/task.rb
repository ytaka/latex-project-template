require 'rake'
require 'rake/tasklib'
require 'filename'

class LaTeXProjectTemplate
  class Cleaning
    include Rake::DSL if defined?(Rake::DSL)

    attr_reader :temporary, :product, :pattern

    DEFAULT_PATTERN = ["**/*~", "**/*.bak", "**/*-SAVE-ERROR"]

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
    COMMAND_TO_PRODUCE_FILE = [:dvi, :ps, :pdf, :pdfdvi, :pdfps]

    include Rake::DSL if defined?(Rake::DSL)

    attr_accessor :path

    def initialize()
      @path = 'latexmk'
      @command = {}

      COMMAND_TO_PRODUCE_FILE.each do |type|
        set(type) do |target|
          "#{@path} -#{type.to_s} #{target}"
        end
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

    (COMMAND_TO_PRODUCE_FILE + [:clean, :distclean]).each do |sym|
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

    def extension_from_command_type(type)
      if /^pdf/ =~ type.to_s
        ".pdf"
      else
        ".#{type.to_s}"
      end
    end
    private :extension_from_command_type

    def snapshot_of_current(type)
      path = FileName.create(@target, :add => :prohibit, :extension => extension_from_command_type(type))
      snapshot_path = FileName.create("snapshot", File.basename(path),
                                      :type => :time, :directory => :parent, :position => :middle,
                                      :delimiter => '', :add => :always, :format => "_%Y%m%d_%H%M%S")
      begin
        Rake::Task[type].execute
      rescue
        $stderr.puts "Can not compile"
      end
      if File.exist?(path)
        move(path, snapshot_path)
        return snapshot_path
      end
      nil
    end
    private :snapshot_of_current

    def commit_date(commit)
      log_data = `git log --date=iso -1 #{commit}`
      if $? == 0
        require 'time'
        l = log_data.split("\n").find { |s| /^Date:.*$/ =~ s }
        Time.parse(l.sub("Date:", ''))
      else
        nil
      end
    end
    private :commit_date

    def extract_source(commit)
      source_directory = FileName.create('src', :type => :time, :directory => :self, :add => :always)
      c = "git archive --format=tar #{commit} | tar -C #{source_directory} -xf -"
      system(c)
      source_directory
    end
    private :extract_source

    def snapshot_of_commit(type, commit)
      if date = commit_date(commit)
        source_directory = extract_source(commit)
        path = FileName.create(source_directory, File.basename(@target), :add => :prohibit, :extension => extension_from_command_type(type))
        path_base = File.basename(path).sub(/\.#{type}$/, "_#{date.strftime("%Y%m%d_%H%M%S")}.#{type}")
        snapshot_path = FileName.create("snapshot", path_base, :directory => :parent, :position => :middle)
        cd source_directory
        begin
          sh "rake #{type}"
        rescue
          $stderr.puts "Can not compile. Please edit files in #{source_directory}."
        end
        if File.exist?(path)
          move(path, snapshot_path)
          cd '..'
          rm_r source_directory
          return snapshot_path
        end
      else
        $stderr.puts "The commit '#{commit}' does not exist."
      end
      nil
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

      Latexmk::COMMAND_TO_PRODUCE_FILE.each do |type|
        desc "Create #{type.to_s}."
        task type => [@target] do |t|
          @latexmk.__send__(type, @target)
        end
      end

      desc "Create snapshot file."
      task :snapshot, [:type,:commit] do |t, args|
        type = args.type && args.type.size > 0 ? args.type.intern : :pdf
        unless Latexmk::COMMAND_TO_PRODUCE_FILE.include?(type)
          raise "Invalid option to produce file: #{type}."
        end
        if commit = args.commit
          path = snapshot_of_commit(type, commit)
        else
          path = snapshot_of_current(type)
        end
        if path
          $stdout.puts "Save to #{path}"
        else
          $stdout.puts "We can not create a file."
        end
      end

      desc "Create source of particular commit."
      task :source, [:commit] do |t, args|
        if commit = args.commit
          if date = commit_date(commit)
            if source_directory = extract_source(commit)
              $stdout.puts "Save to #{source_directory}"
            else
              $stdout.puts "We can not create directory of source files."
            end
          else
            $stderr.puts "The commit '#{commit}' does not exist."
          end
        else
          $stderr.puts "Please set commit."
        end
      end
    end
  end
end
