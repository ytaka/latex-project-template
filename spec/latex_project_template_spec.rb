require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe LaTeXProjectTemplate::Configuration do
  before(:all) do
    @home_directory = File.join(File.dirname(__FILE__), 'test_home')
    @home_directory_absolute = File.expand_path(@home_directory)
  end

  subject do
    LaTeXProjectTemplate::Configuration.new(@home_directory)
  end

  it "should create directory." do
    LaTeXProjectTemplate::Configuration.create_new_config(@home_directory)
    File.directory?(@home_directory).should be_true
    dir = File.join(@home_directory_absolute, '.latex_project_template')
    File.exist?(File.join(dir, 'template')).should be_true
    File.exist?(File.join(dir, 'variable')).should be_true
    File.exist?(File.join(dir, 'component')).should be_true
  end

  it "should return config directory." do
    subject.config_directory.should == File.join(@home_directory_absolute, '.latex_project_template')
  end

  it "should list template." do
    list = subject.list_template
    list.should be_an_instance_of Array
    list.should include('default')
  end

  it "should return path of template." do
    subject.template_exist?('default').should be_an_instance_of LaTeXProjectTemplate::Directory
  end

  it "should return false" do
    subject.template_exist?('not_exist').should be_false
  end

  it "should return profile" do
    vars = subject.user_variables
    vars.should be_an_instance_of Hash
    vars[:profile][:name].should == "Your Name"
  end

  after(:all) do
    FileUtils.rm_r(@home_directory)
  end

end

describe LaTeXProjectTemplate do
  before(:all) do
    @home_directory = File.join(File.dirname(__FILE__), 'test_home')
    @home_directory_absolute = File.expand_path(@home_directory)
    LaTeXProjectTemplate::Configuration.create_new_config(@home_directory)
  end

  it "should copy 'default' template." do
    target = File.join(@home_directory, 'new_tex')
    template = LaTeXProjectTemplate.new(target, 'default', @home_directory)
    template.create
    File.directory?(target).should be_true
    File.directory?(File.join(target, '.git')).should be_true
  end

  it "should copy 'japanese' template." do
    target = File.join(@home_directory, 'new_japanese')
    template = LaTeXProjectTemplate.new(target, 'japanese', @home_directory)
    template.create
    File.directory?(target).should be_true
    File.directory?(File.join(target, '.git')).should be_true
  end

  it "should copy 'default' template without git." do
    target = File.join(@home_directory, 'new_tex_no_git')
    template = LaTeXProjectTemplate.new(target, 'default', @home_directory)
    template.create(:no_git => true)
    File.directory?(target).should be_true
    File.directory?(File.join(target, '.git')).should_not be_true
  end

  after(:all) do
    FileUtils.rm_r(@home_directory)
  end
end
