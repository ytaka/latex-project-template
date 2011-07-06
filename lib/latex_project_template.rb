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
      @config.list_in_directory
    end

    def template_exist?(template)
      @config.exist?(file_path(template))
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


  def initialize(dir, template, config_root = nil)
    @config = LaTeXProjectTemplate::Configuration.new(config_root)
    if @config.template_exist?(template)
      @dir = File.expand_path(dir)
      @template = template
      @main_tex_file = File.basename(dir).sub(/\/$/, '') + ".tex"
    else
      raise "Can not find template: #{@template}"
    end
  end

  def copy_default_to_dir(name, to = nil, io = nil)
    if path = @config.template_file(@template, name)
      FileUtils.cp_r(path, File.join(@dir, to || name))
    end
  end
  private :copy_default_to_dir

  def create_rakefile
    if rakefile_erb = @config.template_file(@template, "Rakefile.erb")
      obj = Object.new
      obj.instance_variable_set(:@main_tex_file, @main_tex_file)
      obj.instance_exec(rakefile_erb, File.join(@dir, 'Rakefile')) do |path, out|
        erb = ERB.new(File.read(path))
        open(out, 'w') do |f|
          f.print erb.result(binding)
        end
      end
    end
  end
  private :create_rakefile

  def create
    @dir = FileName.create(@dir, :directory => :self)
    git = Git.init(@dir)
    copy_default_to_dir('dot.gitignore', '.gitignore')
    copy_default_to_dir('latexmk')
    copy_default_to_dir('template.tex', @main_tex_file)
    create_rakefile
    git.add
    git.commit("Initial commit.")
  end
end
