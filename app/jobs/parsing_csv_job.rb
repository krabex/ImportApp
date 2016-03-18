require 'csv'

#module
  class ParsingCsvJob < Struct.new(:parsing_file_id)
    NB_OF_PARSED_ROWS_NEEDED_TO_UPDATE_STATS = 200

    def perform
      @parsing_file = ParsingFile.find(parsing_file_id)
      @parsing_file.parsing!

      parse_file File.open(@parsing_file.file.path)

      @parsing_file.parsed!
      update_file_stats
    end

    protected

      def parse_file file
        @valid_rows = @parsed = @parsed_after_update_file = 0
        headers = []

        file.each_line do |line|
          begin
            row = CSV.parse_line(line)
        
            if(headers.empty?)
              headers = row
            else
              @valid_rows += 1 if parse_row(headers.zip(row).to_h)
            end
          rescue CSV::MalformedCSVError; end
       
          @parsed += 1
          @parsed_after_update_file += 1
          update_file_stats if @parsed_after_update_file >= NB_OF_PARSED_ROWS_NEEDED_TO_UPDATE_STATS
        end
      end

      def parse_row row
        @company = Company.find_by_name(row["company"].strip) unless row["company"].nil?
        if @company && !row["kind"].nil?  
          @operation = Operation.new({
            invoice_num: row["invoice_num"],
            invoice_date: parse_date(row["invoice_date"]),
            operation_date: parse_date(row["operation_date"]),
            amount: row["amount"],
            reporter: row["reporter"],
            notes: row["notes"],
            status: row["status"],
            kind: row["kind"].downcase
          })
          add_categories(@operation, row["kind"].downcase.split(";"))
          @company.operations << @operation
          return @company.save
        end
        return false
      end

      def add_categories(operation, categories)
        categories.each do |c|
          operation.categories << Category.find_or_create_by(name: c)
        end
      end

      def parse_date(date)
        permitted_formats = ["%m/%d/%Y", "%d-%m-%Y", "%Y-%m-%d"]
      
        begin
          result = DateTime.strptime(date, permitted_formats.shift) unless date.nil?
        rescue ArgumentError
          retry unless permitted_formats.empty?
        end

        result
      end

      def update_file_stats 
        @parsed_after_update_file = 0
        @parsing_file.update_attributes({
          valid_rows: @valid_rows,
          invalid_rows: @parsed - @valid_rows,
          parsed_rows: @parsed
        })
        WebsocketRails[:parsing_file].trigger(:parsing_status, 
          @parsing_file.as_json(only: [:state, :valid_rows, :invalid_rows, :parsed_rows]))
      end

  end
#end
