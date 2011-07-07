require 'fileutils'
require 'erb'
require 'git'
require 'filename'
require 'user_config'

class LaTeXProjectTemplate
  DEFAULT_CONFIG = ".latex_project_template"

  class LPTConfig < UserConfig
  end

  class Configuration
    TEMPLATE_DIRECTORY = 'template'
    VARIABLE_DIRECTORY = 'variable'
    COMPONENT_DIRECTORY = 'component'
    DEFAULT_PROFILE_YAML = { :name => "Your Name" }

    def self.create_new_config(home_path = nil)
      config = LPTConfig.new(DEFAULT_CONFIG, :home => home_path)
      dir = config.directory
      Dir.glob(File.expand_path(File.join(File.dirname(__FILE__), '../initial_files/*'))).each do |path|
        FileUtils.cp_r(path, dir)
      end
      git = Git.init(dir)
      git.add
      git.commit("Create initial template.")
    end

    def initialize(home_path)
      @user_config = LPTConfig.new(DEFAULT_CONFIG, :home => home_path)
    end

    def config_directory
      @user_config.directory
    end

    def list_template
      @user_config.list_in_directory(TEMPLATE_DIRECTORY)
    end

    def user_config_template_path(template_name)
      File.join(TEMPLATE_DIRECTORY, template_name)
    end
    private :user_config_template_path

    def template_exist?(template)
      if path = @user_config.exist?(user_config_template_path(template))
        return LaTeXProjectTemplate::Directory.new(path)
      end
      false
    end

    def delete_template(template)
      if String === template && template.size > 0
        @user_config.delete(user_config_template_path(template))
      else
        raise ArgumentError, "Invalid template name to delete: #{template.inspect}"
      end
    end

    def user_variables
      vars = {}
      if dir = @user_config.exist?('variable')
        Dir.glob(File.join(dir, '*.yaml')).each do |yaml_path|
          key = File.basename(yaml_path).sub(/\.yaml$/, '').intern
          vars[key] = YAML.load_file(yaml_path)
        end
      end
      vars
    end

    def component(name)
      if path = @user_config.exist?(File.join(COMPONENT_DIRECTORY, name))
        return LaTeXProjectTemplate::Component.new(path)
      end
      nil
    end
  end

  class Component
    attr_reader :path

    def initialize(path)
      @path = path
    end

    def evaluate(erb_obj)
      if /\.erb$/ =~ @path
        erb_obj.instance_exec(@path) do |path|
          erb = ERB.new(File.read(path))
          erb.result(binding)
        end
      else
        File.read(@path)
      end
    end
  end

  class Directory
    attr_reader :path, :name

    def initialize(path)
      @path = File.expand_path(path)
      @name = File.basename(@path)
    end

    def create_directory_if_needed(target_dir)
      if File.exist?(target_dir)
        unless File.directory?(target_dir)
          raise "Can not create directory: #{target_dir}"
        end
      else
        File.mkdir_p(target_dir)
      end
    end
    private :create_directory_if_needed

    def target_path(project_name, target_dir, target_name)
      target_name = target_name.gsub(/__DOT__/, '.')
      target_name = target_name.gsub(/__PROJECT__/, project_name)
      File.join(target_dir, target_name.sub(/^#{Regexp.escape(@path)}/, ''))
    end
    private :target_path

    # Create file of which name is created by removing '.erb' from name of original file
    def create_erb_template(erb_file, erb_obj, project_name, target_dir)
      product_path = target_path(project_name, target_dir, erb_file.sub(/\.erb$/, ''))
      erb_obj.instance_exec(erb_file, product_path) do |path, out|
        erb = ERB.new(File.read(path))
        open(out, 'w') do |f|
          f.print erb.result(binding)
        end
      end
      product_path
    end
    private :create_erb_template

    IGNORE_FILE_REGEXP = /(\/__IMPORT__$|\/__IGNORE__|~$)/

    def copy_to_directory(target_dir, erb_binding_obj, files = nil)
      create_directory_if_needed(target_dir)
      if files
        file_list = files.map do |file_path|
          fullpath = File.join(@path, file_path)
          if File.exist?(fullpath)
            fullpath
          else
            nil
          end
        end.compact
      else
        file_list = Dir.glob(File.join(@path, '**', '*')).sort
      end
      created_files = []
      file_list.each do |file|
        next if IGNORE_FILE_REGEXP =~ file
        create_directory_if_needed(File.dirname(file))
        unless File.directory?(file)
          case file
          when /\.erb$/
            created = create_erb_template(file, erb_binding_obj, erb_binding_obj.project_name, target_dir)
          else
            created = target_path(erb_binding_obj.project_name, target_dir, file)
            FileUtils.cp(file, created)
          end
          created_files << created
        end
      end
      created_files
    end

    def files_to_import
      import = Hash.new { |h, k| h[k] = [] }
      import_list_path = File.join(@path, '__IMPORT__')
      if File.exist?(import_list_path)
        File.read(import_list_path).each_line do |l|
          l.strip!
          if n = l.index('/')
            k = l.slice!(0...n)
            import[k] << l[1..-1]
          end
        end
      end
      import
    end
  end

  class ErbObject
    attr_reader :project_name

    def initialize(project_name, variables, config)
      @project_name = project_name
      @__config = config
      variables.each do |key, val|
        instance_variable_set("@#{key}", val)
        self.class.class_eval do
          attr_reader key.intern
        end
      end
    end

    def component(name)
      if c = @__config.component(name)
        c.evaluate(self)
      else
        ''
      end
    end
  end

  def initialize(dir, template, home_directory = nil)
    @config = LaTeXProjectTemplate::Configuration.new(home_directory)
    @target_dir = File.expand_path(dir)
    unless @template = @config.template_exist?(template)
      raise ArgumentError, "Can not find template: #{template}"
    end
    if File.exist?(@target_dir)
      raise ArgumentError, "File #{@target_dir} exists."
    end
    @project_name = File.basename(dir).sub(/\/$/, '')
  end

  def create_files
    erb_obj = LaTeXProjectTemplate::ErbObject.new(@project_name, @config.user_variables, @config)
    created_files = @template.copy_to_directory(@target_dir, erb_obj)
    @template.files_to_import.each do |name, files|
      if template_to_import = @config.template_exist?(name)
        created_files.concat(template_to_import.copy_to_directory(@target_dir, erb_obj, files))
      end
    end
    created_files.sort!
  end
  private :create_files

  def create(opts = {})
    FileUtils.mkdir_p(@target_dir)
    git = Git.init(@target_dir)
    files = create_files
    git.add
    git.commit("Copy template: #{@template.name}.")
    if io = opts[:io]
      files.map! do |path|
        path.sub!(@target_dir, '')
        path.sub!(/^\//, '')
      end
      io.puts "Create the following files from template '#{@template.name}' and commit to git."
      io.puts files.join("\n")
    end
  end
end
