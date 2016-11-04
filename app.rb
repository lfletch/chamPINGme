require_relative 'stripe_key'
require 'sinatra'
require 'stripe'
require 'sqlite3'

Stripe.api_key = $PRIVATE_STRIPE_TEST_KEY
set :public_folder, 'public'

# home page route
get '/' do
  # get list of products -- we'll include these
  # on our store page eventually
  db = SQLite3::Database.new("store.db")
  db.results_as_hash = true
  @products = db.execute("SELECT * from OFFERINGS")

  erb :home
end

# order submission route
post '/purchase' do
  # put form data into variables
  token = params[:stripeToken]
  product_id = params[:product_id].to_i
  product_ids = params[:product_ids].split(',')
  product_ids_i = product_ids.map(&:to_i)
  customer_email = params[:email]
  p product_ids_i
  p params

  # find price for each product
  price = 0
  product_ids_i.each do |product|
    db = SQLite3::Database.new("store.db")
    db.results_as_hash = true
    product = db.execute("SELECT * from OFFERINGS where id=?", product_id).last
    price += product['price']
  end
p price

  # look up price of product
  # db = SQLite3::Database.new("store.db")
  # db.results_as_hash = true
  # product = db.execute("SELECT * from OFFERINGS where id=?", product_id).last
  # price = product['price']

  # create the charge
  charge = Stripe::Charge.create(
  :amount => price,
  :currency => "usd",
  :source => token,
  :description => customer_email
  )

  # print the charge to the server console
  p charge

  redirect '/purchase_confirmation'
end

get '/purchase_confirmation' do
  "Thank you for your purchase. I'll be seeing you soon."
end
