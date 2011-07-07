require 'latex_project_template/task'

describe LaTeXProjectTemplate::Task do
  it "should return default value" do
    LaTeXProjectTemplate::Task.new("sample.tex") do |task|
      task.latexmk.path.should == 'latexmk'
      [:dvi, :ps, :pdf, :pdfdvi, :pdfps, :clean, :distclean].each do |sym|
        task.latexmk.command(sym, "sample.tex").should be_an_instance_of String
      end
    end
  end
end
