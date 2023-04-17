# frozen_string_literal: true

require 'deprecations_collector'

namespace :deprecations do
  desc "Combines all results into one"
  task :combine, [:matrix_folder, :matrix_filename] do |_t, args|
    matrix_folder = args[:matrix_folder].to_s

    combined_matrix = Dir.entries(matrix_folder).select { |f| !f.start_with?('.') }.inject({}) do |temp_matrix, file_name|
      begin
        matrix = YAML.load_file("#{matrix_folder}/#{file_name}")

        temp_matrix.merge(matrix) do |file, oldval, newval|
          oldval.merge(newval) do |line, old_deprecation, new_deprecation|
            old_deprecation + new_deprecation
          end
        end
      rescue Psych::SyntaxError
        temp_matrix
      rescue Errno::EISDIR
        temp_matrix
      end
    end

    DeprecationsCollector::Main.output_path = args[:matrix_folder]
    DeprecationsCollector::Main.save_results(combined_matrix, file_name: args[:matrix_filename])
  end
end
