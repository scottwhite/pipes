class InAppPurchaseController < ApplicationController
  def available_products
    dup = current_user.current_dup
    if(number = dup.first)
      render json: Product.requiring_number(params[:source])
    else
      render json: Product.not_requiring_number(params[:source])
    end
  end

  def verify_purchase

    b64_receipt = params[:receipt]
    url = URI.parse("https://sandbox.itunes.apple.com/verifyReceipt")
     # https://buy.itunes.apple.com/verifyReceipt

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    valid = false
    json_request = {'receipt-data' => b64_receipt}.to_json
    resp = http.post(url.path, json_request.to_s, {'Content-Type' => 'application/x-www-form-urlencoded'})
    logger.info("RESP: #{resp}")
    if resp.code == '200'
      json_resp = JSON.parse(resp.body)
      if json_resp['status'] == 0
        # did = @order.process({raw_status: status , gateway_trans_id: params[:txn_id]})
        valid = true
      end
    end

    render json: {:response => resp.code, :success => valid}
  end


  def create_order
    dup = current_user.current_dup
    pid = params[:product_id]
    if(request.body)
      data = JSON.parse(request.body.read)
      logger.debug(data)
      pid = data["product_id"]
    end
    
    p = Product.first(conditions: {source_product_id: pid})
    unless p
      render json: {message:'no bacon for you'}, status: 400
      return
    end
    o = Order.new
    o.user = current_user
    o.status = Order::INITIAL
    o.product_id = p.id
    o.generate_gateway_token
    o.amount = p.price
    o.save!
    render json: o
  end
end