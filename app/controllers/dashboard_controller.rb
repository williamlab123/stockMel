class DashboardController < ApplicationController
  helper_method :sales

  def sales
    sales_by_month = Sale.where(user_id: session[:user_id]).group_by { |sale| sale.created_at.beginning_of_month }
    @sales_totals_by_month = sales_by_month.map do |month, sales|
      total_price = sales.sum { |sale| sale.total_price || 0 }
      total_quantity = sales.sum { |sale| sale.quantity || 0 }
      [month, [total_price, total_quantity]]
    end.to_h
  end

  def compare_months
    month1 = params[:month1].to_i
    month2 = params[:month2].to_i
    year = params[:year].to_i

    unless (1..12).include?(month1) && (1..12).include?(month2) && year.positive?
      flash[:error] = 'Invalid month or year selected.'
      # redirect_to dashboard_index_path
      return
    end

    sales_totals_by_month = sales

    total_price_month1, total_quantity_month1 = sales_totals_by_month[Date.new(year, month1)] || [0, 0]
    total_price_month2, total_quantity_month2 = sales_totals_by_month[Date.new(year, month2)] || [0, 0]

    @price_difference = total_price_month2 - total_price_month1
    @quantity_difference = total_quantity_month2 - total_quantity_month1
  end

  def index; end

  def show; end
end
