class OrderTrackingController < ApplicationController
	protect_from_forgery
	before_action :set_shop
	def order_webhook
		order = ShopifyAPI::Order.find(params[:id])
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
					"costPerItem": variant.price,
					"hsMainCategory": nil,
					"hsSubCategory": nil,
					"hsCode": nil,
					"weight": variant.weight,
					"width": "1.0",
					"height": "1.0",
					"length": "1.0",
					"manufacturer": line_item["vendor"],
					"model": "Model",
					"color": "Color"
					}
				end
			end
			body = { "elogx-order": {
						"auth": {
							"guid": "319b416d-100c-4f89-af4f-01f2925a1572",
							"username": "npukuk@gmail.com",
							"password": "Mb@nz@_u5a"
						},
						"inbound-shipment": {
							"id": "",
							"trackNo": "",
							"carrier": "SHOPIFY",
							"store": "Shopify"
						},
						"order": {
							"refNo": order.id.to_s,
							"invoiceNo": order.name,
							"orderDate": order.created_at,
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
			@result = HTTParty.post("http://sandbox.elogx.us/api/incoming.aspx?format=json", 
	        :body => body,
	        :headers => { 'Content-Type' => 'application/json' } )
	    	puts "<======result===r=#{@result.parsed_response["elogx-incoming"]["trackNo"]}==sym=#{@result.parsed_response.inspect}===s=#{@result.parsed_response["trackNo"]}==#{@result.parsed_response.class}=>"
	    	track_no = @result.parsed_response["elogx-incoming"]["trackNo"]
	    	order.update_attributes(note: "Tracking No : #{track_no}")
	    end
	end
	def home
		order = ShopifyAPI::Order.find(862897668211)
		puts "<===#{order.inspect}========>"
	end
	def set_shop
		shop_url = "https://daba4fc3c0451ffaa10e613dc73afa6f:cef5a0b6f6995e6b25fa9f0b936e3feb@kivu-noir.myshopify.com/admin"
		ShopifyAPI::Base.site = shop_url	
	end
end
