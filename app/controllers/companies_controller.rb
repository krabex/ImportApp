class CompaniesController < ActionController::Base
  def index
    @companies = Company.all.includes(:operations)
    @stats = @companies.map{ |c| generate_stats(c) }

    respond_to do |format|
      format.json {
        render json: {
          companies: @companies.as_json(include: :operations),
          stats: @stats
        }
      }
    end
  end

  def stats
    @company = Company.find(params[:id])
    @stats = generate_stats @company

    respond_to do |format|
      format.json {
        render json: @stats
      }
    end
  end

  protected
    
    def generate_stats company
      {
        operation_count: company.operations.count,
        operation_amount_average: company.operations.average(:amount),
        operation_max_amount: company.operations.current_month.maximum(:amount),
        accepted_operation_count: company.operations.accepted.count
      }
    end
end 
