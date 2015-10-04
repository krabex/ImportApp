require 'csv'

class ParsingFilesController < ActionController::Base

  def create
    @file = ParsingFile.new(parsing_file_params)
    
    if @file.save
      parse(@file.file.path)
      render json: {
        succeed: true,
        id: @file.id
      }
    else
      render json: { succeed: false }
    end
  end
  
  protected
    def parse(file_path)
      valid_rows = parsed = 0

      file = File.open(file_path)
      headers = []

      file.each_line do |line|
        begin
          row = CSV.parse_line(line)

          if(headers.empty?)
            headers = row
          else
            row = headers.zip(row).to_h
            #logger.info row.inspect
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
              valid_rows += 1 if @company.save
            end
          end
        rescue CSV::MalformedCSVError; end
       
        parsed += 1
      end 
      logger.info valid_rows
    end
    handle_asynchronously :parse

    def add_categories(operation, categories)
      categories.each do |c|
        operation.categories << Category.find_or_create_by(name: c)
      end
    end

    def parse_date(date)
      permitted_formats = ["%m/%d/%Y", "%Y-%m-%d", "%d-%m-%Y"]
      
      begin
        result = DateTime.strptime(date, permitted_formats.shift) unless date.nil?
      rescue ArgumentError
        retry unless permitted_formats.empty?
      end

      result
    end

  private
    def parsing_file_params
      params.permit(:file)
    end

end
