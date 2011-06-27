require 'fileutils'
require 'erb'
require 'git'
require 'filename'

class LaTeXProjectTemplate
  DEFAULT_CONFIG = "~/.latex_project_template"

  class Configuration
    def initialize(path = DEFAULT_CONFIG)
      @path = File.expand_path(path)
    end

    def init_config(path = DEFAULT_CONFIG)
      FileUtils.mkdir_p(@path)
      Dir.glob("#{File.expand_path(File.join(File.dirname(__FILE__), '../template/'))}/*").each do |d|
        FileUtils.cp_r(d, @path)
      end
    end

    def list_template
      Dir.entries(@path).delete_if do |d|
        /^\.+$/ =~ d
      end.sort
    end

    def template_exist?(template)
      path = File.join(@path, template)
      if File.exist?(path)
        path
      else
        nil
      end
    end

    def template_file(template, name)
      path = File.join(@path, template, name)
      unless File.exist?(path)
        path = File.join(@path, 'default', name)
        unless File.exist?(path)
          path = nil
        end
      end
      path
    end

    def delete_template(template)
      if path = template_exist?(template)
        FileUtils.rm_r(path)
      end
    end

  end


  def initialize(dir, template, config = DEFAULT_CONFIG)
    @config = LaTeXProjectTemplate::Configuration.new(config)
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
