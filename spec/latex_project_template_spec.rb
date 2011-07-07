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
    template = LaTeXProjectTemplate.new(File.join(@home_directory, 'new_tex'), 'default', @home_directory)
    template.create
  end

  it "should copy 'japanese' template." do
    template = LaTeXProjectTemplate.new(File.join(@home_directory, 'new_japanese'), 'japanese', @home_directory)
    template.create
  end

  after(:all) do
    FileUtils.rm_r(@home_directory)
  end
end
