# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#   
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Major.create(:name => 'Daley', :city => cities.first)
# 
dids = [
  {
    phone_number: '4434589920',
    state: 'md',
    city: 'annapolis',
    usage_state: Did::ACTIVE
  },
  {
    phone_number: '4434825307',
    state: 'md',
    city: 'annapolis',
    usage_state: Did::ACTIVE
  },
  {
    phone_number: '4434513858',
    state: 'md',
    city: 'baltimore',
    usage_state: Did::ACTIVE
  },
  {
    phone_number: '4434513859',
    state: 'md',
    city: 'baltimore',
    usage_state: Did::ACTIVE
  },
  {
    phone_number: '4434513962',
    state: 'md',
    city: 'baltimore',
    usage_state: Did::ACTIVE
  },
  {
    phone_number: '4434513968',
    state: 'md',
    city: 'baltimore',
    usage_state: Did::ACTIVE
  },
  {
    phone_number: '4434514932',
    state: 'md',
    city: 'baltimore',
    usage_state: Did::ACTIVE
  }
]

dids.each do|did|
  d = Did.find_or_create_by_phone_number(did[:phone_number])
  d.update_attributes!(did)
end


{1=> {p: 3.00, n: 'new'}, 2=> {p: 1.00, n: '30 minute extension'}, 3=>{p: 2.00, n: 'Re-up'}}.each do |k,v|
  p = Product.new(price: v[:p], name: v[:n])
  p.id = k
  p.save!
end

