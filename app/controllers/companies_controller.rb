class CompaniesController < ActionController::Base
  def index
    @companies = Company.all.includes(:operations)
    @stats = []

    @companies.each { |c| @stats << generate_stats(c) }

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
      stats = Hash.new
      stats["operation_count"] = company.operations.count
      stats["operation_amount_average"] = company.operations.average(:amount)
      stats["operation_max_amount"] = company.operations.current_month.maximum(:amount)
      stats["accepted_operation_count"] = company.operations.accepted.count

      return stats
    end
end 
