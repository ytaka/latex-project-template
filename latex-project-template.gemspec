# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{latex-project-template}
  s.version = "0.0.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Takayuki YAMAGUCHI"]
  s.date = %q{2011-07-08}
  s.default_executable = %q{latex-project-template}
  s.description = %q{Create LaTeX project with git from template, which uses latexmk.}
  s.email = %q{d@ytak.info}
  s.executables = ["latex-project-template"]
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.md"
  ]
  s.files = [
    ".document",
    ".rspec",
    "Gemfile",
    "LICENSE.txt",
    "README.md",
    "Rakefile",
    "VERSION",
    "bin/latex-project-template",
    "initial_files/component/math_preamble.tex",
    "initial_files/component/rakefile_common.erb",
    "initial_files/template/default/Rakefile.erb",
    "initial_files/template/default/__DOT__gitignore",
    "initial_files/template/default/__PROJECT__.tex.erb",
    "initial_files/template/japanese/Rakefile.erb",
    "initial_files/template/japanese/__IMPORT__",
    "initial_files/template/japanese/__PROJECT__.tex.erb",
    "initial_files/template/japanese/latexmkrc",
    "initial_files/variable/profile.yaml",
    "latex-project-template.gemspec",
    "lib/latex_project_template.rb",
    "lib/latex_project_template/task.rb",
    "spec/latex_project_template_spec.rb",
    "spec/spec_helper.rb",
    "spec/task_spec.rb"
  ]
  s.homepage = %q{http://github.com/ytaka/latex-project-template}
  s.licenses = ["GPLv3"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{LaTeX Project Template}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rspec>, [">= 2.6.0"])
      s.add_development_dependency(%q<yard>, [">= 0.7.2"])
      s.add_development_dependency(%q<bundler>, [">= 1.0.0"])
      s.add_development_dependency(%q<jeweler>, [">= 1.6.4"])
      s.add_development_dependency(%q<rcov>, [">= 0"])
      s.add_development_dependency(%q<filename>, [">= 0.1.0"])
      s.add_development_dependency(%q<user_config>, [">= 0.0.2"])
      s.add_runtime_dependency(%q<git>, [">= 1.2.5"])
      s.add_runtime_dependency(%q<filename>, [">= 0.1.0"])
      s.add_runtime_dependency(%q<user_config>, [">= 0.0.2"])
    else
      s.add_dependency(%q<rspec>, [">= 2.6.0"])
      s.add_dependency(%q<yard>, [">= 0.7.2"])
      s.add_dependency(%q<bundler>, [">= 1.0.0"])
      s.add_dependency(%q<jeweler>, [">= 1.6.4"])
      s.add_dependency(%q<rcov>, [">= 0"])
      s.add_dependency(%q<filename>, [">= 0.1.0"])
      s.add_dependency(%q<user_config>, [">= 0.0.2"])
      s.add_dependency(%q<git>, [">= 1.2.5"])
      s.add_dependency(%q<filename>, [">= 0.1.0"])
      s.add_dependency(%q<user_config>, [">= 0.0.2"])
    end
  else
    s.add_dependency(%q<rspec>, [">= 2.6.0"])
    s.add_dependency(%q<yard>, [">= 0.7.2"])
    s.add_dependency(%q<bundler>, [">= 1.0.0"])
    s.add_dependency(%q<jeweler>, [">= 1.6.4"])
    s.add_dependency(%q<rcov>, [">= 0"])
    s.add_dependency(%q<filename>, [">= 0.1.0"])
    s.add_dependency(%q<user_config>, [">= 0.0.2"])
    s.add_dependency(%q<git>, [">= 1.2.5"])
    s.add_dependency(%q<filename>, [">= 0.1.0"])
    s.add_dependency(%q<user_config>, [">= 0.0.2"])
  end
end

