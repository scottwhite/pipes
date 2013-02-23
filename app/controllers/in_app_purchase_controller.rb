class InAppPurchaseController < ApplicationController
  def available_products
    dup = current_user.current_dup
    if(number = dup.first)
      render json: Product.requiring_number
    else
      render json: Product.not_requiring_number
    end
  end
end