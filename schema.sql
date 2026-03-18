-- 清除舊表（順序很重要，先刪有 FK 的）
drop table if exists orders cascade;
drop table if exists sessions cascade;
drop table if exists shops cascade;

-- ⓪ shops 表
create table shops (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  subtitle text,
  menu jsonb not null,
  addon_options jsonb default '["珍珠","仙草凍","蜂蜜凍","寒天","蘆薈"]',
  addon_price int default 10,
  ice_options jsonb default '["正常冰","少冰","微冰","去冰","熱飲"]',
  sugar_options jsonb default '["正常甜","少糖","半糖","微糖","無糖"]',
  created_at timestamptz default now()
);

-- ① sessions 表
create table sessions (
  token        text primary key,
  name         text not null,
  created_at   timestamptz default now(),
  closed       boolean default false,
  deadline     timestamptz,
  shop_id      uuid references shops(id)
);

-- ② orders 表
create table orders (
  id           uuid primary key default gen_random_uuid(),
  session_token text references sessions(token) on delete cascade,
  person       text not null,
  person_token text not null,
  drink        text not null,
  size         text,
  ice          text,
  sugar        text,
  addons       text[],
  price        int  not null,
  created_at   timestamptz default now()
);

-- ③ 開啟 Realtime
do $$ begin
  alter publication supabase_realtime add table sessions;
exception when duplicate_object then null;
end $$;
do $$ begin
  alter publication supabase_realtime add table orders;
exception when duplicate_object then null;
end $$;

-- ④ RLS — 全公開讀寫
alter table shops    enable row level security;
alter table sessions enable row level security;
alter table orders   enable row level security;

create policy "public read shops"    on shops    for select using (true);
create policy "public insert shops"  on shops    for insert with check (true);
create policy "public update shops"  on shops    for update using (true);

create policy "public read sessions"  on sessions for select using (true);
create policy "public insert sessions" on sessions for insert with check (true);
create policy "public update sessions" on sessions for update using (true);

create policy "public read orders"   on orders for select using (true);
create policy "public insert orders" on orders for insert with check (true);
create policy "public update orders" on orders for update using (true);
create policy "public delete orders" on orders for delete using (true);

-- ⑤ 插入 TEAMAN 松山門市 菜單
insert into shops (name, subtitle, menu) values (
  'TEAMAN',
  '松山門市',
  '[
    {"cat":"現萃茶","en":"Tea","items":[
      {"name":"蜜香紅茶","en":"Honey Scented Black Tea","flavor":"蜜香、熟果香","price":{"M":40},"fixedSugar":false,"fixedSize":true},
      {"name":"伯爵紅茶","en":"Earl Grey Black Tea","flavor":"果香、柑橘香","price":{"M":45},"fixedSugar":false,"fixedSize":true},
      {"name":"茉香綠茶","en":"Jasmine Green Tea","flavor":"花香、清香","price":{"M":40},"fixedSugar":false,"fixedSize":true},
      {"name":"茶花綠茶","en":"Camelia Green Tea","flavor":"花香、清香","price":{"M":45},"fixedSugar":false,"fixedSize":true},
      {"name":"金萱青茶","en":"Jin Xuan Light Oolong","flavor":"奶香、清香","price":{"M":45},"fixedSugar":false,"fixedSize":true},
      {"name":"雅韻青茶","en":"Yayun Light Oolong","flavor":"花香、輕焙火","price":{"M":45},"fixedSugar":false,"fixedSize":true},
      {"name":"香妃烏龍","en":"Fragrant Oolong Tea","flavor":"奶香、清香","price":{"M":45},"fixedSugar":false,"fixedSize":true},
      {"name":"黃金烏龍茶","en":"Golden Roast Oolong","flavor":"中焙火香","price":{"M":45},"fixedSugar":false,"fixedSize":true},
      {"name":"煙嵐（普洱茶）","en":"Yanlan Pu''er Tea","flavor":"陳香、醇厚","price":{"M":45},"fixedSugar":false,"fixedSize":true},
      {"name":"紅羽（白桃紅茶）","en":"Red Plume Peach Black Tea","flavor":"蜜香、熟果香","price":{"M":45},"fixedSugar":false,"fixedSize":true},
      {"name":"紅烏龍茶","en":"Red Oolong Tea","flavor":"花香、果香、蜜香","price":{"M":50},"fixedSugar":false,"fixedSize":true}
    ]},
    {"cat":"香醇奶茶","en":"Milk Tea","items":[
      {"name":"珍珠奶茶","en":"Bubble Milk Tea","price":{"M":60},"fixedSugar":false,"fixedSize":true},
      {"name":"仙草凍奶茶","en":"Grass Jelly Milk Tea","price":{"M":60},"fixedSugar":false,"fixedSize":true},
      {"name":"蜜香奶茶","en":"Honey Scented Black Milk Tea","price":{"M":60},"fixedSugar":false,"fixedSize":true},
      {"name":"伯爵奶茶","en":"Earl Grey Milk Tea","price":{"M":65},"fixedSugar":false,"fixedSize":true},
      {"name":"茉香奶茶","en":"Jasmine Green Milk Tea","price":{"M":60},"fixedSugar":false,"fixedSize":true},
      {"name":"茶花奶茶","en":"Camelia Green Milk Tea","price":{"M":65},"fixedSugar":false,"fixedSize":true},
      {"name":"金萱奶茶","en":"Jin Xuan Oolong Milk Tea","price":{"M":65},"fixedSugar":false,"fixedSize":true},
      {"name":"雅韻奶茶","en":"Yayun Oolong Milk Tea","price":{"M":65},"fixedSugar":false,"fixedSize":true},
      {"name":"香妃奶茶","en":"Fragrant Oolong Milk Tea","price":{"M":65},"fixedSugar":false,"fixedSize":true},
      {"name":"黃金奶茶","en":"Golden Oolong Milk Tea","price":{"M":65},"fixedSugar":false,"fixedSize":true},
      {"name":"煙嵐奶茶","en":"Yanlan Milk Tea","price":{"M":65},"fixedSugar":false,"fixedSize":true},
      {"name":"紅羽奶茶","en":"Red Plume Milk Tea","price":{"M":65},"fixedSugar":false,"fixedSize":true},
      {"name":"黑糖奶茶","en":"Brown Sugar Milk Tea","price":{"M":70},"fixedSugar":false,"fixedSize":true},
      {"name":"海鹽焦糖奶茶","en":"Sea Salt Caramel Milk Tea","price":{"M":75},"fixedSugar":false,"fixedSize":true}
    ]},
    {"cat":"鮮奶茶拿鐵","en":"Tea Latte","items":[
      {"name":"珍珠紅茶拿鐵","en":"Bubble Black Tea Latte","price":{"M":75},"fixedSugar":false,"fixedSize":true},
      {"name":"仙草凍紅茶拿鐵","en":"Grass Jelly Tea Latte","price":{"M":75},"fixedSugar":false,"fixedSize":true},
      {"name":"蜜香茶拿鐵","en":"Honey Scented Black Tea Latte","price":{"M":75},"fixedSugar":false,"fixedSize":true},
      {"name":"伯爵茶拿鐵","en":"Earl Grey Tea Latte","price":{"M":75},"fixedSugar":false,"fixedSize":true},
      {"name":"茉香茶拿鐵","en":"Jasmine Green Tea Latte","price":{"M":75},"fixedSugar":false,"fixedSize":true},
      {"name":"茶花茶拿鐵","en":"Camelia Green Tea Latte","price":{"M":75},"fixedSugar":false,"fixedSize":true},
      {"name":"金萱茶拿鐵","en":"Jin Xuan Oolong Tea Latte","price":{"M":75},"fixedSugar":false,"fixedSize":true},
      {"name":"雅韻茶拿鐵","en":"Yayun Oolong Tea Latte","price":{"M":75},"fixedSugar":false,"fixedSize":true},
      {"name":"香妃茶拿鐵","en":"Fragrant Oolong Tea Latte","price":{"M":75},"fixedSugar":false,"fixedSize":true},
      {"name":"黃金茶拿鐵","en":"Golden Oolong Milk Tea","price":{"M":75},"fixedSugar":false,"fixedSize":true},
      {"name":"煙嵐茶拿鐵","en":"Yanlan Tea Latte","price":{"M":75},"fixedSugar":false,"fixedSize":true},
      {"name":"紅羽茶拿鐵","en":"Red Plume Tea Latte","price":{"M":75},"fixedSugar":false,"fixedSize":true},
      {"name":"紅烏龍茶拿鐵","en":"Red Oolong Tea Latte","price":{"M":80},"fixedSugar":false,"fixedSize":true},
      {"name":"黑糖紅茶拿鐵","en":"Brown Sugar Tea Latte","price":{"M":85},"fixedSugar":false,"fixedSize":true},
      {"name":"海鹽焦糖茶拿鐵","en":"Sea Salt Caramel Tea Latte","price":{"M":90},"fixedSugar":false,"fixedSize":true}
    ]},
    {"cat":"無咖啡因","en":"Caffeine-Free","items":[
      {"name":"仙草甘茶","en":"Mesona Tea","price":{"M":45},"fixedSugar":false,"fixedSize":true},
      {"name":"甘梅露","en":"Plum Tea","price":{"M":45},"fixedSugar":false,"fixedSize":true},
      {"name":"甘梅露凍飲","en":"Plum Tea with Honey Jelly","price":{"M":55},"fixedSugar":false,"fixedSize":true},
      {"name":"檸檬梅子","en":"Lemon Plum","price":{"M":55},"fixedSugar":false,"fixedSize":true},
      {"name":"葡萄超人","en":"Grape Tea with Agar Jelly & Aloe","price":{"M":60},"fixedSugar":false,"fixedSize":true},
      {"name":"寒天葡萄柚","en":"Grapefruit Tea with Agar Jelly","price":{"M":60},"fixedSugar":false,"fixedSize":true},
      {"name":"黃金蕎麥茶","en":"Buckwheat Tea","price":{"M":45},"fixedSugar":false,"fixedSize":true},
      {"name":"黃金蕎麥茶拿鐵","en":"Buckwheat Tea Latte","price":{"M":75},"fixedSugar":false,"fixedSize":true}
    ]},
    {"cat":"蜂蜜工坊","en":"Honey Series","items":[
      {"name":"蜂蜜綠茶","en":"Honey Green Tea","price":{"M":55},"fixedSugar":true,"fixedSize":true},
      {"name":"蜂蜜煙嵐","en":"Honey Pu''er Tea","price":{"M":60},"fixedSugar":true,"fixedSize":true},
      {"name":"蜂蜜紅烏龍","en":"Honey Red Oolong","price":{"M":65},"fixedSugar":true,"fixedSize":true},
      {"name":"蜂蜜檸檬","en":"Honey Lemon","price":{"M":65},"fixedSugar":true,"fixedSize":true},
      {"name":"寒天蜂蜜","en":"Honey Lemon with Agar Jelly","price":{"M":65},"fixedSugar":true,"fixedSize":true},
      {"name":"蜂蜜檸檬蘆薈","en":"Honey Lemon with Aloe","price":{"M":75},"fixedSugar":true,"fixedSize":true},
      {"name":"蜂蜜奶茶","en":"Honey Milk Tea","price":{"M":75},"fixedSugar":true,"fixedSize":true},
      {"name":"蜂蜜綠茶拿鐵","en":"Honey Green Tea Latte","price":{"M":90},"fixedSugar":true,"fixedSize":true}
    ]},
    {"cat":"風味特調","en":"Flavored","items":[
      {"name":"二號青茶（薄荷風味）","en":"No.2 Light Oolong","price":{"M":50},"fixedSugar":false,"fixedSize":true},
      {"name":"柳橙綠茶","en":"Orange Green Tea","price":{"M":60},"fixedSugar":false,"fixedSize":true},
      {"name":"梅子綠茶","en":"Plum Green Tea","price":{"M":60},"fixedSugar":false,"fixedSize":true},
      {"name":"葡萄紅茶","en":"Grape Black Tea","price":{"M":60},"fixedSugar":false,"fixedSize":true},
      {"name":"百香綠茶","en":"Passionfruit Green Tea","price":{"M":60},"fixedSugar":false,"fixedSize":true},
      {"name":"韓柚烏龍","en":"Korean Yuzu Fragrant Oolong","price":{"M":60},"fixedSugar":false,"fixedSize":true},
      {"name":"韓柚尤青茶","en":"Korean Yuzu Yayun Oolong","price":{"M":60},"fixedSugar":false,"fixedSize":true},
      {"name":"阿梅檸檬綠茶","en":"Lemon Green Tea With Plum","price":{"M":60},"fixedSugar":true,"fixedSize":true},
      {"name":"柚香妃烏龍","en":"Grapefruit Oolong","price":{"M":60},"fixedSugar":true,"fixedSize":true},
      {"name":"柚香紅烏龍","en":"Grapefruit Red Oolong","price":{"M":65},"fixedSugar":true,"fixedSize":true},
      {"name":"小玉烏龍【期間限定】","en":"Watermelon Oolong","price":{"M":65},"fixedSugar":true,"fixedSize":true}
    ]},
    {"cat":"黑糖系","en":"Brown Sugar","items":[
      {"name":"黑糖雙料鮮奶","en":"Brown Sugar Combo Milk","price":{"M":65,"L":80},"fixedSugar":true,"fixedSize":false},
      {"name":"黑糖仙草鮮奶","en":"Brown Sugar Grass Jelly Milk","price":{"M":65,"L":80},"fixedSugar":true,"fixedSize":false},
      {"name":"黑糖珍珠鮮奶","en":"Brown Sugar Bubble Milk","price":{"M":65,"L":80},"fixedSugar":true,"fixedSize":false},
      {"name":"黑糖鮮奶","en":"Brown Sugar Milk","price":{"M":65,"L":80},"fixedSugar":true,"fixedSize":false},
      {"name":"黑糖薑母茶","en":"Brown Sugar Ginger Tea","price":{"M":50,"L":65},"fixedSugar":true,"fixedSize":false},
      {"name":"黑糖薑汁拿鐵","en":"Brown Sugar Ginger Milk","price":{"M":70,"L":85},"fixedSugar":true,"fixedSize":false}
    ]},
    {"cat":"義式咖啡","en":"Espresso","items":[
      {"name":"美式","en":"Americano","price":{"M":50,"L":65},"fixedSugar":false,"fixedSize":false},
      {"name":"密斯朵","en":"Misto","price":{"M":60,"L":75},"fixedSugar":false,"fixedSize":false},
      {"name":"拿鐵","en":"Latte","price":{"M":70,"L":85},"fixedSugar":false,"fixedSize":false},
      {"name":"卡布奇諾","en":"Cappuccino","price":{"M":70,"L":85},"fixedSugar":false,"fixedSize":false},
      {"name":"海鹽焦糖拿鐵","en":"Salted Caramel Latte","price":{"M":85,"L":100},"fixedSugar":false,"fixedSize":false},
      {"name":"西西里","en":"Sicilian Espresso Soda","price":{"M":75},"fixedSugar":false,"fixedSize":true}
    ]},
    {"cat":"厚片","en":"Toast","items":[
      {"name":"花生厚片","en":"Peanut Butter Toast","price":{"M":40},"fixedSugar":true,"fixedSize":true,"noIce":true},
      {"name":"奶酥厚片","en":"Coconut Paste Toast","price":{"M":40},"fixedSugar":true,"fixedSize":true,"noIce":true},
      {"name":"香蒜厚片","en":"Garlic Butter Toast","price":{"M":40},"fixedSugar":true,"fixedSize":true,"noIce":true},
      {"name":"巧克力厚片","en":"Chocolate Toast","price":{"M":40},"fixedSugar":true,"fixedSize":true,"noIce":true}
    ]}
  ]'::jsonb
);
