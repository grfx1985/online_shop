# {Payment} class helper methods.
# Kind'a serializer like ;) 
# @author Pawel Adamski 
module PaymentsHelper
  # prepares card_params for {PayLane::Client}#card_* methods
  def card_params user, card, address, ip, order
    c_params = {
        'sale' => {
            'amount'      => order.price,
            'currency'    => 'PLN',
            'description' => "Fitnoteq #{user.subscription_label}, Order ID. #{order.id}"

        },
        'customer' => {
            'name'    => user.name,
            'email'   => user.email,
            'ip'      => ip,
            'address' => address
        },
        'card' => {
            'card_number'      => card.card_number,
            'expiration_month' => card.expiration_month,
            'expiration_year'  => card.expiration_year,
            'name_on_card'     => card.name_on_card,
            'card_code'        => card.card_code,
        }
    }
  end
  # prepares paypal_params for {PayLane::Client}#paypal_* methods
  def paypal_params user, back_url, order
    pp_params = {
          'sale' => {
            'amount'      => order.price,
            'currency'    => 'PLN',
            'description' => "Fitnoteq #{user.subscription_label}"
        },
        'back_url' =>   "#{back_url}/callback"
    }
  end
  # prepares resale_params for {PayLane::Client}#resale_* methods
  def resale_params method, last_id, user
    field = method == 'sale'? 'id_sale' : 'id_authorization'
    resale_params = {
        field => last_id,
        'amount'           => user.subscription_price,
        'currency'         => 'PLN',
        'description'      => 'Fitnoteq #{user.subscription_label}, Order ID. #{order.id}'
    }

  end
end
