# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#   
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Major.create(:name => 'Daley', :city => cities.first)
# 

{
  1=> {p: 3.00, n: 'new', s: 'web', i: '', a:false, t: 'PIPES_NUMBER'}, 
  2=> {p: 1.00, n: '30 minute extension', s: 'web', i:'', a:true, t: 'PIPES_EXTEND'}, 
  3=>{p: 2.00, n: 'Re-up',  s: 'web', i:'', a:true, t: 'REUP_20MINS'},
  4=> {p: 2.99, n: 'IOS Pipes Number', s: 'apple', i: 'pipesnumber', a:false, t: 'PIPES_NUMBER'}, 
  5=> {p: 0.99, n: 'IOS 30 minute extension', s: 'apple', i:'pipesextension', a:true, t: 'PIPES_EXTEND'}, 
  6=>{p: 1.99, n: 'IOS 20 Minute Re-up',  s: 'apple', i:'pipesminutes', a:true, t: 'REUP_20MINS'},
  7=> {p: 3.00, n: 'Pipes Number', s: 'google', i: 'pipes_number', a:false, t: 'PIPES_NUMBER'}, 
  8=> {p: 1.00, n: '30 minute extension', s: 'google', i:'pipes_extend_30mins', a:true, t: 'PIPES_EXTEND'}, 
  9=>{p: 2.00, n: 'Re-up',  s: 'google', i:'pipes_reup_default', a:true, t: 'REUP_20MINS'}
}.each do |k,v|
  p = Product.new(price: v[:p], name: v[:n],  source: v[:s],
    source_product_id: v[:i], requires_existing: v[:a],
    product_type: v[:t])
  p.id = k
  p.save!
end

