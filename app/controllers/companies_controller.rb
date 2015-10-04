class CompaniesController < ActionController::Base
  def index
    @companies = Company.all.includes(:operations)

    respond_to do |format|
      format.json {
        render json: @companies, include: :operations
      }
    end
  end

  def stats
    @company = Company.find(params[:id])

    @stats = Hash.new
    @stats["operation_count"] = @company.operations.count
    @stats["operation_amount_average"] = @company.operations.average(:amount)
    @stats["operation_max_amount"] = @company.operations.current_month.maximum(:amount)
    @stats["accepted_operation_count"] = @company.operations.accepted.count

    respond_to do |format|
      format.json {
        render json: @stats
      }
    end
  end
end 
