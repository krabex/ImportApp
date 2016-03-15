class DownloadsController < ActionController::Base

  def export_csv
    @download = Download.create!(name: DateTime.now.strftime("%d_%m_%Y_%s.csv"))

    Delayed::Job.enqueue ::ExportOperationsToCsvJob.new(@download.id, params[:filter])

    respond_to do |format|
      format.json {
        render json: {
          id: @download.id
        }
      }
    end
  end

  def show
    @download = Download.find(params[:id])
    
    send_file @download.name if @download.ready_to_download?  
  end

end
