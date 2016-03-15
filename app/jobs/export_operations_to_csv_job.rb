require 'csv'

#module
  class ExportOperationsToCsvJob < Struct.new(:download_id, :filter)
    NB_OF_ROWS_NEEDED_TO_UPDATE_STATS = 300

    def perform
      @download = Download.find(download_id)
      @download.preparing_file!
      
      @operations = load_operations
      @generated_rows = 0
      @generated_rows_after_update = 0

      file_path = Rails.root.join("public", "downloads", @download.name)
      CSV.open(file_path, "w") do |csv|
        csv << csv_header
        @operations.each do |op|
          csv << csv_row(op)
          @generated_rows += 1
          @generated_rows_after_update += 1
          update_download_stats if @generated_rows_after_update > NB_OF_ROWS_NEEDED_TO_UPDATE_STATS
        end
      end

      @download.ready_for_download!
      update_download_stats
    end

    protected

      def load_operations
        return Operation.all.includes(:company) if filter.nil?

        Operation.where("invoice_num = :filter or reporter = :filter or status = :filter or kind = :filter",
          {filter: filter})
          .includes(:company)
      end

      def update_download_stats
        @download.update_attributes({
          progress: (@generated_rows*100 / @operations.count).to_i
        })

        @generated_rows_after_update = 0
        res = {
          state: @download.state,
          progress: @download.progress,
          url: "/downloads/" + @download.name
        }
        WebsocketRails[:exporting_file].trigger(:exporting_status, res.as_json())
      end

      def csv_row(op)
        [op.company.name, op.invoice_num, op.invoice_date.strftime("%Y-%d-%m"), op.operation_date.strftime("%Y-%d-%m"), 
         op.amount, op.reporter, op.notes, op.status, op.kind]
      end

      def csv_header
        ["company", "invoice_num", "invoice_date", "operation_date", 
         "amount", "reporter", "notes", "status", "kind"]
      end

  end
#end
