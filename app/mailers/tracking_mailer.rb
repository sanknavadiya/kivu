class TrackingMailer < ApplicationMailer
	def track_order(tracking_no,customer_email,order_no)
    @tracking_no = tracking_no
    @order_no = order_no
    mail(to: customer_email, subject: "Your order is on the way")
  end
end
