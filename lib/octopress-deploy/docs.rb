module Octopress
  module Deploy
    class DeployDocs < Octopress::Ink::Plugin
      def configuration
        {
          name:        "Octopress Deploy",
          description: "Deploy your site with Git, Rsync or S3.",
          slug:        "deploy",
          assets_path: Octopress::Deploy.gem_dir('assets'),
          version:     Octopress::Deploy::VERSION,
        }
      end

      def docs_base_path
        'docs/deploy'
      end
    end
  end
end
