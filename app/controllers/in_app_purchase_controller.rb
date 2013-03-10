class InAppPurchaseController < ApplicationController
  def available_products
    dup = current_user.current_dup
    if(number = dup.first)
      render json: Product.requiring_number(params[:source])
    else
      render json: Product.not_requiring_number(params[:source])
    end
  end


  def verify_apple_purchase

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
    pipes_number = params[:number]
    if(request.body)
      data = JSON.parse(request.body.read)
      logger.debug(data)
      pid = data["product_id"] || pid
      pipes_number = data["number"] || pipes_number
    end
    
    p = Product.first(conditions: {source_product_id: pid})
    unless p
      render json: {message:'no bacon for you'}, status: 400
      return
    end
    unless p.can_order?(current_user.first_did)
      render json: {message:'Invalid product request'}, status: 400
      return
    end
    o = Order.new
    o.user = current_user
    o.status = Order::INITIAL
    o.product_id = p.id
    o.generate_gateway_token
    o.amount = p.price
    o.pipes_number = pipes_number || current_user.first_did.phone_number
    o.save!
    render json: o
  end

# POST, trans_id
  def finalize_order
    trans_id = params[:trans_id]
    if(request.body)
      data = JSON.parse(request.body.read)
      logger.debug(data)
      trans_id = data["trans_id"]
    end
    unless trans_id
      render json: {message:'seriously? No bacon for you'}, status: 400
      return
    end
    order = Order.find_by_gateway_trans_id(trans_id)
    if order.blank? || order.user != current_user
      render json: {message:'order not found'}, status: 400
      return
    end
    if(order.processed?)
      render json: {message:'order already completed'}, status: 400
      return      
    end
    did = order.process_in_app();
    unless(did)
      render json: {message:'order has gone horribly wrong'}, status: 400
      return      
    end
    dup = did.dids_user_phone
    render json: {dup_id: dup.id, did_id: did.id, expired: did.expired?, 
        can_reup: did.can_reup? , 
        time_allotted: dup.time_allotted, 
        time_left: dup.time_left, 
        expiration_date: dup.expiration_date, 
        number: did.phone_number}
  end
end