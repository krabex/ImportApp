class ParsingFilesController < ActionController::Base

  def create
    @file = ParsingFile.new(parsing_file_params)
    
    if @file.save
      Delayed::Job.enqueue ::ParsingCsvJob.new(@file.id)
      render json: {
        succeed: true,
        id: @file.id
      }
    else
      render json: { succeed: false }
    end
  end

  def state
    @file = ParsingFile.find(params[:id])

    respond_to do |format|
      format.json {
        render json: @file, only: [:parsed_rows, :valid_rows, :invalid_rows, :state]
      }
    end
  end

  private
    def parsing_file_params
      params.permit(:file)
    end

end
