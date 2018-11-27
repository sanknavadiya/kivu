class OrderTrackingController < ApplicationController
	protect_from_forgery
	before_action :set_shop
	def order_webhook
		order = ShopifyAPI::Order.find(params[:id])

		# live auth details
		auth_detail = {
			"guid": "A6605248-2356-43B8-BD5B-4BBF378D0DA7",
			"username": "npukuk@gmail.com",
			"password": "Mb@nz@_u5a"
		}
		domain_name = "https://www.elogx.us"
		# sandbox auth details
		# auth_detail = {
		# 			"guid": "319b416d-100c-4f89-af4f-01f2925a1572",
		# 			"username": "npukuk@gmail.com",
		# 			"password": "Mb@nz@_u5a"
		# 		}
		# domain_name = "http://sandbox.elogx.us"
		unless order.note.include?("Tracking No")
			product_array = []
			params[:line_items].each do |line_item|
				product = ShopifyAPI::Product.find(line_item["product_id"])
				variant = ShopifyAPI::Variant.find(line_item["variant_id"])
				if product.tags.include?("elogX order")
					product_array << {
					"barcode": variant.barcode,
					"prodName": product.title,
					"numItems": line_item["quantity"],
					"costPerItem": variant.price
					}
				end
			end
			if product_array.present?
				body = { "elogx-order": {
							"auth": auth_detail,
							"order": {
								"refNo": order.id.to_s,
								"invoiceNo": order.name,
								"orderDate": order.created_at.to_date.strftime("%Y-%m-%d"),
								"company": order.shipping_address.company,
								"instructions": "Shopify Order",
								"delivery-address": {
									"person": order.shipping_address.name.to_s,
									"tel": order.shipping_address.phone,
									"email": order.email,
									"street": order.shipping_address.address1,
									"suburb": order.shipping_address.province,
									"city": order.shipping_address.city,
									"stateCode": order.shipping_address.province_code,
									"zipCode": order.shipping_address.zip,
									"countryCode": order.shipping_address.country_code
								}
							},
							"product": product_array
		                 }}.to_json
		                 puts "<===req body====#{body.inspect}====================>"

				# @result = HTTParty.post("http://sandbox.elogx.us/api/place-order.aspx?format=json",
				@result = HTTParty.post("#{domain_name}/api/place-order.aspx?format=json",
		        :body => body,
		        :headers => { 'Content-Type' => 'application/json' } )
		    	puts "<======result===r=#{@result.parsed_response}==sym=#{@result.parsed_response.inspect}===s=#==#{@result.parsed_response.class}=>"
		    	track_no = @result.parsed_response["elogx-order"]["refNo"]
		    	order.update_attributes(note: "Tracking No : #{track_no}")

		    	track_body = {
								"elogx-smart-track": {
									"auth": auth_detail,
									"filter": {
										"refNo": ["#{order.name.to_s}"],
										"trackNo": []
									}
								}
							}.to_json
                 	puts "<===req body===t=#{track_body.inspect}====================>"
		    	@result_track = HTTParty.post("#{domain_name}/api/smart-track.aspx?format=json",
		        :body => track_body,
		        :headers => { 'Content-Type' => 'application/json' } )
		    	puts "<=====t=result===r=#{@result_track.parsed_response}==sym=#{@result_track.parsed_response.inspect}====>"
		    	render json: {}, status: 200
		    end
	    end
	end
	def home
		# order = ShopifyAPI::Order.find(862897668211)
		# puts "<===#{order.inspect}========>"
	end
	def set_shop
		shop_url = "https://daba4fc3c0451ffaa10e613dc73afa6f:cef5a0b6f6995e6b25fa9f0b936e3feb@kivu-noir.myshopify.com/admin"
		ShopifyAPI::Base.site = shop_url	
	end
end
