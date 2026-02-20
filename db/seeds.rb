# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# db/seeds.rb
require "open-uri"


# Helper to seed ecommerce-like products with nicer names/descriptions
def seed_ecommerce_products(count = 10)
  samples = [
    { name: "Aria Linen Shirt", keywords: "linen shirt,clothing", description: "Lightweight breathable linen shirt with a relaxed fit — perfect for warm-weather layering." },
    { name: "Cascade Denim Jacket", keywords: "denim jacket,outerwear", description: "Classic denim jacket with reinforced stitching and a timeless silhouette." },
    { name: "Nova Sneakers", keywords: "sneakers,shoes", description: "Everyday sneakers with cushioned sole and durable canvas upper for all-day comfort." },
    { name: "Mercury Leather Wallet", keywords: "leather wallet,accessory", description: "Slim handcrafted leather wallet with multiple card slots and RFID protection." },
    { name: "Solstice Sunglasses", keywords: "sunglasses,accessory", description: "UV400 polarized lenses with lightweight acetate frames — modern and protective." },
    { name: "Lumen Floor Lamp", keywords: "floor lamp,lighting,home", description: "Minimal floor lamp with warm LED light and adjustable shade for cozy ambient lighting." },
    { name: "Harbor Ceramic Mug", keywords: "ceramic mug,home,kitchen", description: "Stoneware mug with comfortable handle and dishwasher-safe glaze — holds 12oz." },
    { name: "Everest Backpack", keywords: "backpack,bag,outdoor", description: "Durable pack with padded laptop sleeve, water-resistant fabric, and ergonomic straps." },
    { name: "Breeze Cotton T-Shirt", keywords: "cotton t-shirt,clothing", description: "Soft-ring spun cotton tee with a modern cut — wardrobe essential." },
    { name: "Atlas Coffee Maker", keywords: "coffee maker,kitchen,appliance", description: "Compact drip coffee maker with programmable timer and thermal carafe." }
  ]

  count.times do |i|
    sample = samples[i % samples.length]
    p = Product.create!(
      name: sample[:name],
      description: sample[:description],
      price: (rand(1999..9999) / 100.0),
      stock_quantity: rand(5..100)
    )

    # try to attach a relevant Unsplash image; if it fails, continue without image
    begin
      url = "https://source.unsplash.com/1200x800/?#{URI.encode_www_form_component(sample[:keywords])},product,#{i}"
      file = URI.open(url)
      p.image.attach(io: file, filename: "product-ecom-#{p.id}.jpg", content_type: "image/jpeg")
      file.close
      puts "Seeded #{p.name} with image"
    rescue => e
      puts "Seeded #{p.name} without image (#{e.message})"
    end
  end
end

# If there are no products, create 10 ecommerce-style products instead of the generic set
if Product.count == 0
  seed_ecommerce_products(10)
end

