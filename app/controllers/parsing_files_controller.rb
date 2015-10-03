class ParsingFilesController < ActionController::Base

  def create
    @file = ParsingFile.new(parsing_file_params)
    
    if @file.save
      render json: {
        succeed: true,
        id: @file.id
      }
    else
      render json: { succeed: false }
    end
  end
  
  private
    def parsing_file_params
      params.permit(:file)
    end

end