class DownloadsController < ActionController::Base

  def export_csv
    logger.info "begin"
    @download = Download.create!(name: "test.csv")

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
