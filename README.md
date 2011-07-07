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

- git
- filename
- user_config

## Install

We can install by rubygems.

    gem install latex-project-template

## Special notations of template file names

\_\_IMPORT\_\_
:In \_\_IMPORT\_\_ we write list of files to import from other template.
\_\_PROJECT\_\_
:Replace \_\_PROJECT\_\_ by name of project.
\_\_DOT\_\_
:Replace \_\_DOT\_\_ by '.'.
\_\_IGNORE\_\_
:Files including \_\_IGNORE\_\_ are ignored.

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

