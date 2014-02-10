# Octopress Deploy

Deployment tools for Octopress and Jekyll blogs.

## Installation

Add this line to your application's Gemfile:

    gem 'octopress-deploy'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install octopress-deploy-git

## Deploying with Git

This is a generic git deployment system, it should work for GitHub, Heroku and other similar hosts.

#### 1. Add a `_deploy.yml` configuration file to your project root.

For GitHub user pages, the url should be something like: `git@github.com:username.github.io` and the branch should be master.
For project pages, the url should be the path to the project repo and the branch should be `gh-pages`.

```yml
site: _site
git:
  url: [git url]
  branch: master
```

#### 2. From Ruby run:

```ruby
Octopress::Deploy::Git.new().push
```

### Options

It is recommended that you configure using the `deploy.yml`, but you can also pass configuration as options.

| option        | Description                                      | Default
|:--------------|:-------------------------------------------------|:---------------|
| `config_file` | Path to the config file.                         | _config.yml    |
| `site_dir`    | Path to comipled site files.                     | _site          |
| `git_url`     | Url for remote git repository.                   |                |
| `git_branch`  | Deployment branch for git repository.            | master         |
| `deploy_dir`  | Directory where deployment files are staged.     | .deploy        |
| `remote`      | Name of git remote.                              | deploy         |


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

Copyright (c) 2014 Brandon Mathis

MIT License

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
