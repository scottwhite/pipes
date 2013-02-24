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

# dids.each do|did|
#   d = Did.find_or_create_by_phone_number(did[:phone_number])
#   d.update_attributes!(did)
# end


{
  1=> {p: 3.00, n: 'new', s: 'web', i: '', a:false, t: 'PIPES_NUMBER'}, 
  2=> {p: 1.00, n: '30 minute extension', s: 'web', i:'', a:true, t: 'PIPES_EXTEND'}, 
  3=>{p: 2.00, n: 'Re-up',  s: 'web', i:'', a:true, t: 'REUP_20MINS'},
  4=> {p: 2.99, n: 'IOS Pipes Number', s: 'apple', i: 'pipesnumber', a:false, t: 'PIPES_NUMBER'}, 
  5=> {p: 0.99, n: 'IOS 30 minute extension', s: 'apple', i:'pipesextension', a:true, t: 'PIPES_EXTEND'}, 
  6=>{p: 1.99, n: 'IOS 20 Minute Re-up',  s: 'apple', i:'pipesminutes', a:true, t: 'REUP_20MINS'}
}.each do |k,v|
  p = Product.new(price: v[:p], name: v[:n],  source: v[:s],
    source_product_id: v[:i], requires_existing: v[:a],
    product_type: v[:t])
  p.id = k
  p.save!
end

