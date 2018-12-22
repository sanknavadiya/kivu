namespace :maintain_stock do
	desc "task about synchronise the stock with e-logx"
	task synchronise_stock: :environment do
		shop_url = "https://daba4fc3c0451ffaa10e613dc73afa6f:cef5a0b6f6995e6b25fa9f0b936e3feb@kivu-noir.myshopify.com/admin"
		ShopifyAPI::Base.site = shop_url
		@shop = ShopifyAPI::Shop.current
		@fromDate = "2018-01-01 01:00" #(Date.today - 1.day).beginning_of_day.strftime("%Y-%m-%d %H:%M")
		@toDate = Time.now.strftime("%Y-%m-%d %H:%M")
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
		@page = 1
		loop do
			body = {"elogx-get-received-stock": {
				"auth": auth_detail,
				"filter": {
					"fromDate": @fromDate,
					"toDate": @toDate,
					"pgSize": 20,
					"pgNum": @page
				}
			}}.to_json

			@result = HTTParty.post("#{domain_name}/api/get/received/stock",
		        :body => body,
		        :headers => { 'Content-Type' => 'application/json' } )
					puts "<===products====#{@result.parsed_response.inspect}====>"
			@result.parsed_response["item"].each do |item|
				# @variants = ShopifyAPI::Variant.where(barcode: item["barcode"])
				@variants = ShopifyAPI::Variant.where(barcode: item["barcode"], :params => {:limit => 250})
				@variants.each do |variant|
					if variant.barcode == item["barcode"]
						puts "inside if--------#{variant.inventory_quantity.class}----#{item["inStock"].class}->"
						unless variant.inventory_quantity == item["inStock"]
							@level = ShopifyAPI::InventoryLevel.find(:all, params: {inventory_item_ids: variant.inventory_item_id, location_ids: @shop.primary_location_id})
							puts "<==test=====#{@level.inspect}========>"
							@level.first.set(item["inStock"])
						end
						break
					end
				end
			end
			break unless @result.parsed_response["item"].present?
			@page += 1
		end
	end
end