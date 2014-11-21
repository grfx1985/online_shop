module Api
  module V1
    class LineItemsController < ApplicationController
      respond_to :json
      
      def index
        respond_with LineItem.all
      end
      
      def show
        respond_with LineItem.find(params[:id])
      end
      
      def create
        respond_with LineItem.create(params[:line_item])
      end
      
      def update
        respond_with LineItem.update(params[:id], params[:line_item])
      end
      
      def destroy
        respond_with LineItem.destroy(params[:id])
      end
    end
  end
end


