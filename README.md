# Octopress Deploy

Easily deploy any Jekyll or Octopress site using S3, Git or Rsync.

Pull request to support other deployment methods are welcome.

[![Gem Version](http://img.shields.io/gem/v/octopress-deploy.svg)](https://rubygems.org/gems/octopress-deploy)
[![License](http://img.shields.io/:license-mit-blue.svg)](http://octopress.mit-license.org)

## Installation

To use Octopress Deploy, first install the Octopress gem with `gem install octopress` or by adding it to your Gemfile.

## Set up

First set up a configuration file for your deployment method.

```sh
$ octopress deploy init git  # or rsync, s3
```

This will generate a `_deploy.yml` file in your current
directory which you can edit to add any necessary configuration.
**Remember to add your configuration to `.gitignore` to be sure
you never commit sensitive information to your repository.**

## Deploying your site.

Deployment is tailored to work with Jekyll, but it will work for
any static site. Simply make sure your configuration points to
the root directory of your static site (For Jekyll, that's
probably `_site`) then tell Octopress to deploy it.

```sh
$ octopress deploy
```

This will read your `_deploy.yml` configuration and deploy your
site. If you like, you can specify a configuration file.

```sh
$ octopress deploy --config _staging.yml
```

## Pull down your site

With the `pull` command, you can pull your site down into a local directory.

```sh
octopress deploy pull <DIR>
```

Mainly you'd do this if you're troubleshooting deployment and you want to see if it's working how you expected.

## Amazon S3 Deployment Configuration

To deploy with Amazon S3 you will need to install the [aws-sdk gem](https://rubygems.org/gems/aws-sdk).

Important: when using S3, you must add your `_deploy.yml` to your .gitignore to prevent accidentally sharing
account access information.

| Config              | Description                                           | Default
|:--------------------|:------------------------------------------------------|:-------------|
| `method`            | Deployment method, in this case use 's3'              |              |
| `site_dir`          | Path to static site files                             | _site        |
| `bucket_name`       | S3 bucket name                                        |              |
| `access_key_id`     | AWS access key                                        |              |
| `secret_access_key` | AWS secret key                                        |              |
| `remote_path`       | Directory files should be synced to.                  | /            |
| `verbose`           | [optional] Display all file actions during deploy.    | true         |
| `region`            | [optional] Region for your AWS bucket                 | us-east-1    |
| `delete`            | Delete files in `remote_path` not found in `site_dir` | false        |
| `headers`           | Set headers for matched files                         | []           |

If you choose a bucket which doesn't yet exist, Octopress Deploy will offer to create it for you, and offer to configure it as a static website.

If you configure Octopress to delete files, all files found in the `remote_path` on S3 bucket will be removed unless they match local site files.
If `remote_path` is a subdirectory, only files in that subdirectory will be evaluated for deletion.


### S3 Headers

You can create an array of header congifs to set expiration, content and cache settings for any paths matching the `filename`.

| Header Config       | Description                                           | Default
|:--------------------|:------------------------------------------------------|:-------------|
| `filename`          | A regex or a substring of the file to match           |              |
| `site_dir`          | An http date or a number of years or days from now    |              |
| `content_type`      | A string which is passed through to the headers       |              |
| `content_encoding`  | A string which is passed through to the headers       |              |
| `cache_control`     | A string which is passed through to the headers       |              |

Here is how you might set expriation and cache controls for CSS and Javascript files.

```yaml
headers:
  - filename: '^assets.*\.js$'
    expires: '+3 years'
    cache_control: 'max-age=94608000'
    content_type: 'application/javascript'
  - filename: '^assets.*\.css$'
    expires: '+3 years'
    cache_control: 'max-age=94608000'
    content_type: 'text/css'
```

### AWS config via ENV

If you prefer, you can store AWS access credentials in environment variables instead of a configuration file. 

| Config              | ENV var                        |
|:--------------------|:-------------------------------|
| `access_key_id`     | AWS_ACCESS_KEY_ID              |
| `secret_access_key` | AWS_SECRET_ACCESS_KEY          |

Note: configurations in `_deploy.yml` will override environment variables so be sure to remove those if you decide to use environment variables.

### Add a new bucket

If your AWS credentials are properly configured, you can add a new bucket with this command.

```sh
octopress deploy add-bucket
```

This will connect to AWS, create a new S3 bucket, and configure it for static website hosting. This command can use the settings in your deployment configuration or you can pass options to override those settings.

| Option        | Description                                      | Default
|:--------------|:-------------------------------------------------|:---------------|
| `--name`      | Override the `bucket_name` configuration         |                |
| `--region`    | Override the `region` configuration              |                |
| `--index`     | Specify an index page for your site              | index.html     |
| `--error`     | Specify an error page for your site              | error.html     |
| `--config`    | Use a custom configuration file                  | _deploy.yml    |

You'll only need to pass options if you want to override settings in your deploy config file.

## Git Deployment Configuration

Only `git_url` is required. Other options will default as shown below.

| Config        | Description                                      | Default
|:--------------|:-------------------------------------------------|:---------------|
| `method`      | Deployment method, in this case use 'git'        |                |
| `site_dir`    | Path to static site files                        | _site          |
| `git_url`     | Url for remote git repository                    |                |
| `git_branch`  | Deployment branch for git repository             | master         |
| `deploy_dir`  | Directory where deployment files are staged      | .deploy        |
| `remote`      | Name of git remote                               | deploy         |

## Rsync Deployment Configuration

| Config         | Description                                       | Default
|:---------------|:--------------------------------------------------|:---------------|
| `method`       | Deployment method, in this case use 'rsync'       |                |
| `site_dir`     | Path to static site files                         | _site          |
| `user`         | ssh user, e.g user@host.com                       |                |
| `port`         | ssh port                                          | 22             |
| `remote_path`  | Remote destination's document root                |                |
| `exclude_file` | Path to a file containing rsync exclusions        |                |
| `exclude`      | Inline list of rsync exclusions                   |                |
| `include`      | Inline list of inclusions to override exclusions  |                |
| `delete`       | Delete files in destination not found in source   | false          |

You can rsync to a local directory by configuring `remote_path` and leaving off `user` and `port`.

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
