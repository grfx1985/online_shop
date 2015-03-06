module Api
  module V1
    class OrdersController < ApplicationController
      respond_to :json
      
      def index
        respond_with Order.all
      end
      
      def show
        respond_with Order.find(params[:id])
      end
      
      def create
        o = o_p.except(:delivery_time)
        o[:delivery_time] = Time.at(o_p[:delivery_time].to_i)
        respond_with Order.create(o)
      end
      
      def update
        respond_with Order.update(params[:id], params[:order])
      end
      
      def destroy
        respond_with Order.destroy(params[:id])
      end
      private
      def o_p
        params.require(:order).permit(:name,:address,:email,:pay_type,:extra,:shipped,:doc,:delivery_time)
      end
    end
  end
end


