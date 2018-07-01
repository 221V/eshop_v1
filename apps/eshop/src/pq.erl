-module(pq).
-compile([export_all, nowarn_export_all]).

%postgresql queries module

% get_all_cities()
% update_city_by_id(City_Id, City_Name, City_Pop)
% add_city(City_Name, City_Pop)
% add_city_return_id(City_Name, City_Pop)
% delete_city_by_id(City_Id)
% update_user_money(Worker, User_Id, Money)
% 
% get_all_orders_adminka_list(Limit, Offset)
% get_order_by_id(OId)
% upd_order_status_by_id(OId, Val)
% get_orders_count()
% get_new_orders()
% get_orderedok_orders()
% get_categories()
% get_category_by_id(Cat_Id)
% get_category_by_name(Name)
% get_category_childs_by_id(Cat_Id)
% upd_category_status_by_id(Cat_Id, Val)
% upd_category_order_by_id(Cat_Id, Val)
% upd_category_name_by_id(Cat_Id, Val)
% upd_category_parent_by_ids(Cat_Id, Parent_Id)
% add_category(Name, Parent)
% get_user_login(Email)
% add_full_image(UId, GId, Path, Name)
% add_mini_image(UId, GId, Path, Name, Status)
% get_mini_image(GId, Path, Name, Status)
% upd_image_gid(Id, GId)
% get_image_status(Id)
% upd_image_status(Id, Status)
% get_image_order(Id)
% upd_image_order(Id, Order)
% get_active_images_by_gid(GId)
% get_all_images_by_gid(GId)
% get_all_images_by_uid(UId)
% get_goods_main_by_rate(Limit, Offset)
% get_goods_main_by_lowprice(Limit, Offset)
% get_goods_main_by_hightprice(Limit, Offset)
% get_goods_category_by_rate(Category_Id, Limit, Offset)
% get_goods_category_by_lowprice(Category_Id, Limit, Offset)
% get_goods_category_by_hightprice(Category_Id, Limit, Offset)
% get_goods_count()
% get_allactive_goods_count()
% get_catactive_goods_count(Cat_Id)
% get_all_goods_adminka_list(Limit, Offset)
% get_goods_adminka_by_id(GId)
% add_new_good(UId, Title2, Title_Img2, Preview_BB1, Preview_HTML, Full_BB1, Full_HTML, Cat_Id, Price, Available_Status, Status)
% update_good_by_id(GId, Title2, Title_Img2, Preview_BB1, Preview_HTML, Full_BB1, Full_HTML, Cat_Id, Price, Available_Status, Status)
% update_good_html_by_id(GId, Title2, Title_Img2, Preview_HTML, Full_HTML, Cat_Id, Price, Available_Status, Status)
% upd_good_rate_by_id(GId)
% add_new_order(Name,Phone,Email,Text,GoodsInfo)
% 



%get_all_cities() ->
%  pg:select("SELECT id, name, population FROM test ORDER BY id", []).


%update_city_by_id(City_Id, City_Name, City_Pop) ->
%  pg:in_up_del("UPDATE test SET name = $1, population = $2 WHERE id = $3", [City_Name, City_Pop, City_Id]).


%add_city(City_Name, City_Pop) ->
%  pg:in_up_del("INSERT INTO test (name, population) VALUES ($1, $2)", [City_Name, City_Pop]).


%add_city_return_id(City_Name, City_Pop) ->
%  pg:returning("INSERT INTO test (name, population) VALUES ($1, $2) RETURNING id", [City_Name, City_Pop]).


%delete_city_by_id(City_Id) ->
%  pg:in_up_del("DELETE FROM test WHERE id = $1", [City_Id]).


%update_user_money(Worker, User_Id, Money) ->
%  pg:transaction_q(Worker, "UPDATE test_users SET money = $1 WHERE id = $2 ", [Money, User_Id]).


get_all_orders_adminka_list(Limit, Offset) ->
  pg:select("SELECT id, user_name, user_phone, user_email, user_text, goods_info, status, inserted_at FROM eshop_orders ORDER BY status ASC, id DESC LIMIT $1 OFFSET $2", [Limit, Offset]).


get_order_by_id(OId) ->
  pg:select("SELECT id, user_name, user_phone, user_email, user_text, goods_info, status, inserted_at FROM eshop_orders WHERE id = $1 LIMIT 1", [OId]).


upd_order_status_by_id(OId, Val) ->
  pg:in_up_del("UPDATE eshop_orders SET status = $1 WHERE id = $2", [Val, OId]).


get_orders_count() ->
  pg:select("SELECT COUNT(id) FROM eshop_orders", []).


get_new_orders() ->
  pg:select("SELECT id, user_name, user_phone, user_email, user_text, goods_info, inserted_at FROM eshop_orders WHERE status = 1 ORDER BY id DESC", []).


get_orderedok_orders() ->
  pg:select("SELECT id, user_name, user_phone, user_email, user_text, goods_info, inserted_at FROM eshop_orders WHERE status = 2 ORDER BY id DESC", []).


get_categories() ->
  pg:select("SELECT id, name, parent, status, ordering FROM eshop_categories ORDER BY parent ASC, ordering ASC", []).


get_category_by_id(Cat_Id) ->
  pg:select("SELECT name, parent, ordering FROM eshop_categories WHERE id = $1 LIMIT 1", [Cat_Id]).


get_category_by_name(Name) ->
  pg:select("SELECT id FROM eshop_categories WHERE name = $1 LIMIT 1", [Name]).


get_category_childs_by_id(Cat_Id) ->
  pg:select("SELECT id, name FROM eshop_categories WHERE parent = $1 ORDER BY ordering ASC", [Cat_Id]).


upd_category_status_by_id(Cat_Id, Val) ->
  pg:in_up_del("UPDATE eshop_categories SET status = $1 WHERE id = $2", [Val, Cat_Id]).


upd_category_order_by_id(Cat_Id, Val) ->
  pg:in_up_del("UPDATE eshop_categories SET ordering = $1 WHERE id = $2", [Val, Cat_Id]).


upd_category_name_by_id(Cat_Id, Val) ->
  pg:in_up_del("UPDATE eshop_categories SET name = $1 WHERE id = $2", [Val, Cat_Id]).


upd_category_parent_by_ids(Cat_Id, Parent_Id) ->
  pg:in_up_del("UPDATE eshop_categories SET parent = $1 WHERE id = $2", [Parent_Id, Cat_Id]).


add_category(Name, Parent) ->
  pg:in_up_del("INSERT INTO eshop_categories (name, path, parent, ordering) VALUES ($1, $2, $3, 10)", [Name, "0", Parent]).


get_user_login(Email) ->
  pg:select("SELECT id, password, status FROM eshop_admins WHERE email = $1 LIMIT 1", [Email]).


add_full_image(UId, GId, Path, Name) ->
  pg:in_up_del("INSERT INTO eshop_all_imgs (uid, gid, path, name) VALUES ($1, $2, $3, $4)", [UId, GId, Path, Name]).


add_mini_image(UId, GId, Path, Name, Status) ->
  pg:in_up_del("INSERT INTO eshop_all_imgs (uid, gid, path, name, status) VALUES ($1, $2, $3, $4, $5)", [UId, GId, Path, Name, Status]).


get_mini_image(GId, Path, Name, Status) ->
  pg:select("SELECT id FROM eshop_all_imgs WHERE gid = $1 AND status = $2 AND path = $3 AND name = $4 LIMIT 1", [GId, Status, Path, Name]).


upd_image_gid(Id, GId) ->
  pg:in_up_del("UPDATE eshop_all_imgs SET gid = $1 WHERE id = $2", [GId, Id]).


get_image_status(Id) ->
  pg:select("SELECT status FROM eshop_all_imgs WHERE id = $1 LIMIT 1", [Id]).


upd_image_status(Id, Status) ->
  pg:in_up_del("UPDATE eshop_all_imgs SET status = $1 WHERE id = $2", [Status, Id]).


get_image_order(Id) ->
  pg:select("SELECT \"order\" FROM eshop_all_imgs WHERE id = $1 LIMIT 1", [Id]).


upd_image_order(Id, Order) ->
  pg:in_up_del("UPDATE eshop_all_imgs SET \"order\" = $1 WHERE id = $2", [Order, Id]).


get_active_images_by_gid(GId) ->
  pg:select("SELECT id, path, name FROM eshop_all_imgs WHERE gid = $1 AND status <> 0 ORDER BY \"order\"", [GId]).


get_all_images_by_gid(GId) ->
  pg:select("SELECT id, uid, path, name, status, \"order\" FROM eshop_all_imgs WHERE gid = $1 ORDER BY status ASC, \"order\" ASC", [GId]).


get_all_images_by_uid(UId) ->
  pg:select("SELECT id, gid, path, name, status, \"order\" FROM eshop_all_imgs WHERE uid = $1 ORDER BY \"order\"", [UId]).


get_goods_main_by_rate(Limit, Offset) ->
  pg:select("SELECT id, title, img_title, html_preview_text, bought_count, price, available_status FROM eshop_goods WHERE status = 1 ORDER BY available_status ASC, bought_count DESC, id ASC LIMIT $1 OFFSET $2", [Limit, Offset]).


get_goods_main_by_lowprice(Limit, Offset) ->
  pg:select("SELECT id, title, img_title, html_preview_text, bought_count, price, available_status FROM eshop_goods WHERE status = 1 ORDER BY available_status ASC, price ASC, bought_count DESC LIMIT $1 OFFSET $2", [Limit, Offset]).


get_goods_main_by_hightprice(Limit, Offset) ->
  pg:select("SELECT id, title, img_title, html_preview_text, bought_count, price, available_status FROM eshop_goods WHERE status = 1 ORDER BY available_status ASC, price DESC, bought_count DESC LIMIT $1 OFFSET $2", [Limit, Offset]).


get_goods_category_by_rate(Category_Id, Limit, Offset) ->
  pg:select("SELECT id, title, img_title, html_preview_text, bought_count, price, available_status FROM eshop_goods WHERE category_id = $1 AND status = 1 ORDER BY available_status ASC, bought_count DESC, id ASC LIMIT $2 OFFSET $3", [Category_Id, Limit, Offset]).


get_goods_category_by_lowprice(Category_Id, Limit, Offset) ->
  pg:select("SELECT id, title, img_title, html_preview_text, bought_count, price, available_status FROM eshop_goods WHERE category_id = $1 AND status = 1 ORDER BY available_status ASC, price ASC, bought_count DESC LIMIT $2 OFFSET $3", [Category_Id, Limit, Offset]).


get_goods_category_by_hightprice(Category_Id, Limit, Offset) ->
  pg:select("SELECT id, title, img_title, html_preview_text, bought_count, price, available_status FROM eshop_goods WHERE category_id = $1 AND status = 1 ORDER BY available_status ASC, price DESC, bought_count DESC LIMIT $2 OFFSET $3", [Category_Id, Limit, Offset]).


get_goods_count() ->
  pg:select("SELECT COUNT(id) FROM eshop_goods", []).


get_allactive_goods_count() ->
  pg:select("SELECT COUNT(id) FROM eshop_goods WHERE status = 1", []).


get_catactive_goods_count(Cat_Id) ->
  pg:select("SELECT COUNT(id) FROM eshop_goods WHERE category_id = $1 AND status = 1", [Cat_Id]).


get_all_goods_adminka_list(Limit, Offset) ->
  pg:select("SELECT id, title, img_title, html_preview_text, price, available_status, status FROM eshop_goods ORDER BY id DESC LIMIT $1 OFFSET $2", [Limit, Offset]).


get_goods_adminka_by_id(GId) ->
  pg:select("SELECT id, title, img_title, bb_preview_text, html_preview_text, bb_full_text, html_full_text, category_id, bought_count, price, available_status, status FROM eshop_goods WHERE id = $1 LIMIT 1", [GId]).


add_new_good(UId, Title2, Title_Img2, Preview_BB1, Preview_HTML, Full_BB1, Full_HTML, Cat_Id, Price, Available_Status, Status) ->
  pg:in_up_del("INSERT INTO eshop_goods (author_id, title, img_title, bb_preview_text, html_preview_text, bb_full_text, html_full_text, category_id, price, available_status, status) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)", [UId, Title2, Title_Img2, Preview_BB1, Preview_HTML, Full_BB1, Full_HTML, Cat_Id, Price, Available_Status, Status]).


update_good_by_id(GId, Title2, Title_Img2, Preview_BB1, Preview_HTML, Full_BB1, Full_HTML, Cat_Id, Price, Available_Status, Status) ->
  pg:in_up_del("UPDATE eshop_goods SET title = $1, img_title = $2, bb_preview_text = $3, html_preview_text = $4, bb_full_text = $5, html_full_text = $6, category_id = $7, price = $8, available_status = $9, status = $10 WHERE id = $11", [Title2, Title_Img2, Preview_BB1, Preview_HTML, Full_BB1, Full_HTML, Cat_Id, Price, Available_Status, Status, GId]).


update_good_html_by_id(GId, Title2, Title_Img2, Preview_HTML, Full_HTML, Cat_Id, Price, Available_Status, Status) ->
  pg:in_up_del("UPDATE eshop_goods SET title = $1, img_title = $2, html_preview_text = $3, html_full_text = $4, category_id = $5, price = $6, available_status = $7, status = $8 WHERE id = $9", [Title2, Title_Img2, Preview_HTML, Full_HTML, Cat_Id, Price, Available_Status, Status, GId]).


upd_good_rate_by_id(GId) ->
  pg:in_up_del("UPDATE eshop_goods SET bought_count = bought_count + 1 WHERE id = $1", [GId]).


add_new_order(Name,Phone,Email,Text,GoodsInfo) ->
  pg:in_up_del("INSERT INTO eshop_orders (user_name, user_phone, user_email, user_text, goods_info) VALUES ($1, $2, $3, $4, $5)", [Name,Phone,Email,Text,GoodsInfo]).




