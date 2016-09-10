module Fastlane
  module Actions
    module SharedValues
    end

    require 'fileutils'
    class ModifyMigratedRepoAction < Action
      def self.run(params)
        script_path = "#{File.dirname(File.dirname(File.dirname(__FILE__)))}/scripts/custom"
        Dir.mktmpdir do |tmpdir|
          UI.message "Cloning Repository from #{params[:repo_url]} into #{tmpdir}"
          clone_result = Actions.sh("git clone #{params[:repo_url]} #{tmpdir}")
          if clone_result.include?("warning: You appear to have cloned an empty repository.")
              UI.message "Skipping empty repository #{params[:to_repo_url]}"
          else
            Dir.chdir(tmpdir) do
              # changes (rename ruby hack /  hook external script)
              if params[:custom_script]
                UI.message "Running custom script #{params[:custom_script]}"
                Actions.sh("/bin/bash #{script_path}/#{params[:custom_script]}")
              end
              Actions.sh("git push --all origin")
            end
          end
        end
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Fire Customization scripts to modify a git repository"
      end

      def self.details
        "Fire Customization scripts to modify a git repository"
      end

      def self.available_options
        # Define all options your action supports.
        [
          FastlaneCore::ConfigItem.new(key: :repo_url,
           env_name: "FL_MIGRATE_GIT_REPOSITORY_TO_REPO_URL",
           description: "The url of the target remote to which the repository should be migrated",
           verify_block: proc do |value|
            raise "No Destination URL for MigrateGitRepositoryAction given, pass using `to_repo_url: 'url'`".red unless (value and not value.empty?)
          end),
          FastlaneCore::ConfigItem.new(key: :custom_script,
           env_name: "FL_MIGRATE_GIT_CUSTOM_SCRIPT",
           is_string: true,
           optional: true,
           description: "Custom script to be executed between the clone and the push on the destination server",
           )
        ]
      end

      def self.output
        # Define the shared values you are going to provide
        []
      end

      def self.return_value
        # If you method provides a return value, you can describe here what it does
      end

      def self.authors
        # So no one will ever forget your contribution to fastlane :) You are awesome btw!
        ["msutter"]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
