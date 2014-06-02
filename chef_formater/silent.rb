require_relative 'color_diff'

class Chef
  module Formatters
    class Silent < Formatters::Minimal

      cli_name :silent

      def run_start(version)
        puts "Starting Chef Client, version #{version}"
      end

      def run_completed(node)
        puts "Chef client finished, #{@updated_resources.size} resources updated"
      end

      def run_failed(exception)
        puts "Chef client failed. #{@updated_resources.size} resources updated"
      end

      def cookbook_resolution_start(expanded_run_list)
        puts "Resolving cookbooks for run list: #{expanded_run_list.inspect}"
      end

      def cookbook_sync_start(cookbook_count)
        puts 'Synchronizing cookbooks'
      end

      def synchronized_cookbook(cookbook_name)
      end

      def cookbook_sync_complete

      end

      def library_load_start(file_count)
      end

      def file_loaded(path)
      end

      def recipe_load_complete;
      end

      def converge_start(run_context)
      end

      def converge_complete;
      end

      def resource_skipped(resource, action, conditional)
      end

      def resource_up_to_date(resource, action)
      end

      def msg(message)
      end

      def resource_update_applied(resource, action, update)
        @updates_by_resource[resource.name] << Array(update)[0]
      end

      def resource_updated(resource, action)

        if resource.kind_of?(Chef::Resource::File)
          if resource.diff
            print '=' * 80 + "\n"
            ColorDiff.print_diff resource.diff.split('\n')
            print '=' * 80 + "\n"
          end
        end

        if resource.kind_of?(Chef::Resource::Package)
          print " \n"
          if resource.version
            print("* Install package #{resource.name} version #{resource.version} \n", :green)
          else
            print("* Remove package #{resource.name} \n", :red)
          end
          print " \n"
        end

        updated_resources << resource
      end

      def display_error(description)
        puts('')
        description.display(output)
      end

      #
      # Очень хотим красивые fail
      #

      def registration_failed(node_name, exception, config)
        description = ErrorMapper.registration_failed(node_name, exception, config)
        display_error(description)
      end

      def node_load_failed(node_name, exception, config)
        description = ErrorMapper.node_load_failed(node_name, exception, config)
        display_error(description)
      end

      def run_list_expand_failed(node, exception)
        description = ErrorMapper.run_list_expand_failed(node, exception)
        display_error(description)
      end

      def cookbook_resolution_failed(expanded_run_list, exception)
        description = ErrorMapper.cookbook_resolution_failed(expanded_run_list, exception)
        display_error(description)
      end

      def cookbook_sync_failed(cookbooks, exception)
        description = ErrorMapper.cookbook_sync_failed(cookbooks, exception)
        display_error(description)
      end

      def resource_failed(resource, action, exception)
        description = ErrorMapper.resource_failed(resource, action, exception)
        display_error(description)
      end

    end
  end
end
