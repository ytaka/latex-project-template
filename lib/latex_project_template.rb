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
    def self.create_new_config(home_path = nil)
      config = LPTConfig.new(DEFAULT_CONFIG, :home => home_path)
      dir = config.directory
      Dir.glob("#{File.expand_path(File.join(File.dirname(__FILE__), '../template/'))}/*").each do |d|
        FileUtils.cp_r(d, dir)
      end
    end

    def initialize(home_path)
      @config = UserConfig.new(DEFAULT_CONFIG, :home => home_path)
    end

    def config_directory
      @config.directory
    end

    def list_template
      @config.list_in_directory('.')
    end

    def template_exist?(template)
      if path = @config.exist?(template)
        return LaTeXProjectTemplate::Directory.new(path)
      end
      false
    end

    def template_file(template, name)
      unless path = @config.template_exist?(File.join(template, name))
        path = @config.template_exist?(File.join('default', name))
      end
      path
    end

    def delete_template(template)
      if String === template && template.size > 0
        @config.delete(template)
      else
        raise ArgumentError, "Invalid template name to delete: #{template.inspect}"
      end
    end
  end

  class Directory
    def initialize(path)
      @path = File.expand_path(path)
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

    def target_path(target_dir, target_name)
      if /\/__DOT__/ =~ target_name
        target_name = target_name.sub(/\/__DOT__/, '/.')
      end
      File.join(target_dir, target_name.sub(/^#{Regexp.escape(@path)}/, ''))
    end
    private :target_path

    # Create file of which name is created by removing '.erb' from name of original file
    def create_erb_template(erb_file, erb_obj, target_dir)
      erb_obj.instance_exec(erb_file, target_path(target_dir, erb_file.sub(/\.erb$/, ''))) do |path, out|
        erb = ERB.new(File.read(path))
        open(out, 'w') do |f|
          f.print erb.result(binding)
        end
      end
    end
    private :create_erb_template

    IGNORE_FILE_REGEXP = /\/(__IMPORT__$|__IGNORE__)/

    def copy_to_directory(target_dir, erb_binding_obj, files = nil)
      create_directory_if_needed(target_dir)
      if files
        file_list = files.map do |file_path|
          File.join(@path, file_path)
        end
      else
        file_list = Dir.glob(File.join(@path, '**', '*')).sort
      end
      file_list.each do |file|
        next if IGNORE_FILE_REGEXP =~ file
        create_directory_if_needed(File.dirname(file))
        if File.directory?(file)
          FileUtils.mkdir_p(file)
        else
          case file
          when /\.erb$/
            create_erb_template(file, erb_binding_obj, target_dir)
          else
            FileUtils.cp(file, target_path(target_dir, file))
          end
        end
      end
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
    erb_obj = Object.new
    erb_obj.instance_variable_set(:@project_name, @project_name)
    @template.copy_to_directory(@target_dir, erb_obj)
    @template.files_to_import.each do |name, files|
      if template_to_import = @config.template_exist?(name)
        template_to_import.copy_to_directory(@target_dir, erb_obj, files)
      end
    end
  end
  private :create_files

  def create
    FileUtils.mkdir_p(@target_dir)
    git = Git.init(@target_dir)
    create_files
    git.add
    git.commit("Initial commit.")
  end
end
