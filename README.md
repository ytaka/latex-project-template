# latex-project-template

Management of latex template files.
latex-project-template creates a latex project directory from a template
in ~/.latex\_project\_template.
The directory is git repository and includes Rakefile to compile
a latex file with latexmk.

- <http://rubygems.org/gems/latex-project-template>
- <https://github.com/ytaka/latex-project-template>

## Requirements

latex-project-template uses latexmk to compile latex files and
the project directory is managed by git.

- [latexmk](http://www.phys.psu.edu/~collins/software/latexmk-jcc/)
- [Git](http://git-scm.com/)
- some LaTeX environment

latex-project-template depends on the following gems.

- [git](http://rubygems.org/gems/git)
- [filename](http://rubygems.org/gems/filename)
- [user_config](http://rubygems.org/gems/user_config)

## Installation

We can install by rubygems.

    gem install latex-project-template

## Usage

If we install latex-project-template, we can use the command 'latex-project-template'.
First of all, we create configuration directory ~/.latex\_project\_template.

    latex-project-template --init

Next, we edit template files in ~/.latex\_project\_template.
If we want to create latex project 'new_project' from 'default' template, type

    latex-project-template new_project

If we want to create from other template (for example, 'japanese'),
we type next command.

    latex-project-template new_project japanese

To list templates in ~/.latex\_project\_template, we type

    latex-project-template --list

## Structure of template

In ~/.latex\_project\_template there are the following directories.

- template
- component
- variable
- .git

### 'template' directory

'template' directory includes main files of templates.
A template is a directory in 'template' directory and
all files are fundamentally copied to a project directory.
We can write template files with format simple texts or eruby files.

If we want to create dynamically files then we use eruby.
Files with the extension '.erb' is an eruby template and
latex-project-template evaluates them when copying a template as a specified project.

#### Special notations of template file names

Some special notations of template file names also are used.
The following strings starting \_\_ and ending \_\_ have special meanings.

\_\_IMPORT\_\_
: In \_\_IMPORT\_\_ we write list of files to import from other template.

\_\_PROJECT\_\_
: Replace \_\_PROJECT\_\_ by name of project.

\_\_DOT\_\_
: Replace \_\_DOT\_\_ by '.'.

\_\_IGNORE\_\_
: Files including \_\_IGNORE\_\_ are ignored.

### 'component' directory

Common parts of template files are placed.
In order to import into eruby templates, we use 'component' method.
If there is 'component/rakefile_common.erb',
we can use this file in eruby template.

    <%= component('rakefile_common.erb') %>    

### 'variable' directory

The 'variable' directory has yaml files,
which are used in eruby template.
We can get the object of 'filename.yaml',
referring to 'filename';

For example, if there is variable/profile.yaml' like

    ---
    :name: Your Name

then we can refer to the above value as in 'template/default/\_\_PROJECT\_\_.tex.erb'

    <%= profile[:name] %>

## Rake tasks

Tasks to compile latex files with latexmk are defined in 'latex\_project\_template/task.rb'.
To investigate usage of the file,
we can see Rakefile in 'default' template.

## Contributing to latex-project-template
 
- Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
- Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
- Fork the project
- Start a feature/bugfix branch
- Commit and push until you are happy with your contribution
- Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
- Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2011 Takayuki YAMAGUCHI. See LICENSE.txt for
further details.

