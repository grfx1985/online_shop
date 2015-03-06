module Api
  module V1
    class ContactsController < ApplicationController
      respond_to :json
      
      def index
        respond_with Contact.all
      end
      
      def show
        respond_with Contact.find(params[:id])
      end
      
      def create
        respond_with Contact.create(params[:contact])
      end
      
      def update
        respond_with Contact.update(params[:id], params[:contact])
      end
      
      def destroy
        respond_with Contact.destroy(params[:id])
      end
    end
  end
end


