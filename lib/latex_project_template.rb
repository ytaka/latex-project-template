autoload :FileUtils, 'fileutils'
autoload :ERB, 'erb'

gem 'git'
autoload :Git, 'git'

gem 'filename'
autoload :FileName, 'filename'

class LaTeXProjectTemplate
  DEFAULT_CONFIG = "~/.latex_project_template"

  def self.init_config(path = DEFAULT_CONFIG)
    target = File.expand_path(path)
    FileUtils.mkdir_p(target)
    Dir.glob("#{File.expand_path(File.join(File.dirname(__FILE__), '../template/'))}/*").each do |d|
      FileUtils.cp_r(d, target)
    end
  end

  def initialize(dir, template, config = DEFAULT_CONFIG)
    @config = File.expand_path(config)
    if template_exist?(template)
      @dir = FileName.create(dir, :directory => :self)
      @template = template
      @main_tex_file = File.basename(dir).sub(/\/$/, '') + ".tex"
    else
      raise "Can not find template: #{@template}"
    end
  end

  def template_exist?(template)
    File.exist?(File.join(@config, template))
  end
  private :template_exist?

  def template_file_path(name)
    path = File.join(@config, @template, name)
    unless File.exist?(path)
      path = File.join(@config, 'default', name)
      unless File.exist?(path)
        path = nil
      end
    end
    path
  end
  private :template_file_path

  def copy_default_to_dir(name, to = nil, io = nil)
    if path = template_file_path(name)
      FileUtils.cp_r(path, File.join(@dir, to || name))
    #   if io
    #     io.puts "Copy #{name} in #{@config}"
    #   end
    # else
    #   if io
    #     io.puts "Can not find #{name} in #{@config}"
    #   end
    end
  end
  private :copy_default_to_dir

  def create_rakefile
    if rakefile_erb = template_file_path("Rakefile.erb")
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

  def init
    git = Git.init(@dir)
    copy_default_to_dir('dot.gitignore', '.gitignore')
    copy_default_to_dir('latexmk')
    copy_default_to_dir('template.tex', @main_tex_file)
    create_rakefile
    git.add
    git.commit("Initial commit.")
  end
end
