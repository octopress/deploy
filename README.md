# Octopress Deploy

Deployment tools for Octopress and Jekyll blogs (or really any static site).

Currently this supports deploying through S3, Git and Rsync. Requests for other
deployment methods are welcome.

## Installation

Add this line to your application's Gemfile:

    gem 'octopress-deploy'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install octopress-deploy

## Set up

To deploy your site run:

```bash
$ octopress deploy
```

This will read from your configuration file `_deploy.yml` and deploy your site. If your site has no configuration file, you will be asked if you want to generate one and what deployment method you want to use.

You can also generate a `./_deploy.yml` configuration file by running:

```bash
$ octopress deploy init git # or 'rsync' or 's3'
```

Once you've deployed your site, you can also pull it back down into a local directory. This is mostly useful for checking the results of a deploy. This will create the directory if it doesn't already exist.

```ruby
Octopress::Deploy.pull('some_directory')
```

### Configuration options

Configurations should be added to a `_deploy.yml` file in your project's root directory. You can pass options as a hash directy to the `push` method as well. Passed options will override options set in the config file.

| Config        | Description                                      | Default
|:--------------|:-------------------------------------------------|:---------------|
| `config_file` | Path to the config file.                         | _config.yml    |
| `site_dir`    | Path to comipled site files.                     | _site          |


#### Amazon S3

Important: when using S3, you must add your _deploy.yml to your .gitignore to prevent accidentally sharing
account access information. Octopress Deploy will offer to do it for you. If you don't, you won't be able to deploy.`

| Config              | Description                              | Default
|:--------------------|:-----------------------------------------|:-------------|
| `bucket_name`       | S3 bucket name                           |              |
| `access_key_id`     | AWS access key                           |              |
| `secret_access_key` | AWS secret key                           |              |
| `remote_path`       | Directory files should be synced to.     | /            |
| `delete`            | Delete files to create a 1:1 file sync.  | false        |
| `verbose`           | Display all file actions during deploy.  | true         |
| `region`            | Region for your AWS bucket               | us-east-1    |

If you choose a bucket which doesn't yet exist, Octopress Deploy will offer to create it for you, and offer to configure it as a static website.

##### ENV config

For the following configurations you can set environment vars instead of adding items to your config file.

| Config              | ENV var                        |
|:--------------------|:-------------------------------|
| `access_key_id`     | AWS_ACCESS_KEY_ID              |
| `secret_access_key` | AWS_SECRET_ACCESS_KEY          |
| `region`            | AWS_DEFAULT_REGIONS            |


##### Deleting files from S3

If the `delete` option is true, files in the `remote_path` on the bucket will be removed if they do not match local site files.
If `remote_path` is a subdirectory, only files in that subdirectory will be evaluated for deletion.

#### Git

Only `git_url` is required. Other options will default as shown below.

| Config        | Description                                      | Default
|:--------------|:-------------------------------------------------|:---------------|
| `git_url`     | Url for remote git repository.                   |                |
| `git_branch`  | Deployment branch for git repository.            | master         |
| `deploy_dir`  | Directory where deployment files are staged.     | .deploy        |
| `remote`      | Name of git remote.                              | deploy         |

#### Rsync

Only `remote_path` is required. If `user` is not present, Rsync will sync between two locally available directories. Do this if your site root is mounted locally.

| Config         | Description                                       | Default
|:---------------|:--------------------------------------------------|:---------------|
| `user`         | ssh user, e.g user@host.com                       |                |
| `port`         | ssh port                                          | 22             |
| `remote_path`  | Remote destination's document root.               |                |
| `exclude_file` | Path to a file containing rsync exclusions.       |                |
| `exclude`      | Inline list of rsync exclusions.                  |                |
| `include`      | Inline list of inclusions to override exclusions. |                |
| `delete`       | Delete files in destination not found in source   | false          |

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
