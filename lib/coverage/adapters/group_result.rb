
module Adapters
  class GroupResult 
    def initialize(group: )
      @group = group
    end

    def covered_percentage
      return 0 if group_files.count.zero?

      total_percetage = group_files.map { |f| f['covered_percent'] }.sum
      (total_percetage / group_files.count) * 100
    end


    def group_files
      files.select do |file|
        file["filename"].match?(@group)
      end
    end

    def files
      result["files"]
    end

    def result
      @result ||= JSON.parse(File.read(Configuration.coverage_json_path))
    end
  end
end
