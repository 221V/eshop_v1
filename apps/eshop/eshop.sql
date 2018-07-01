

DROP TABLE IF EXISTS eshop_admins;
CREATE TABLE "eshop_admins" (
  "id" bigserial NOT NULL,
  "email" varchar(255) NOT NULL,
  "password" varchar(255) NOT NULL,
  "status" smallint NOT NULL DEFAULT 1,
  --not_activated:0, active: 1, banned: 2, deleted: 3
  "inserted_at" TIMESTAMP NOT NULL DEFAULT LOCALTIMESTAMP(0),
  PRIMARY KEY ("id")
);

-- pass: 123123123
INSERT INTO "eshop_admins" (email, password) VALUES ('test777@gmail.com', 'D20221D888703C4754E8117EF8E15B68BA27A144D9DC2C1FF4084CA8F2D4748EBCA0781C31361E3A8FFF51D12E77B3FBD8037A620338B10DF492B9DAA41ABDD5');
INSERT INTO "eshop_admins" (email, password) VALUES ('test999@gmail.com', 'D20221D888703C4754E8117EF8E15B68BA27A144D9DC2C1FF4084CA8F2D4748EBCA0781C31361E3A8FFF51D12E77B3FBD8037A620338B10DF492B9DAA41ABDD5');


DROP TABLE IF EXISTS eshop_goods;
CREATE TABLE "eshop_goods" (
  "id" bigserial NOT NULL,
  "author_id" bigint NOT NULL,
  -- references eshop_admins id
  "title" varchar(255) NOT NULL,
  "img_title" varchar(255) NOT NULL,
  "bb_preview_text" text NOT NULL,
  "html_preview_text" text NOT NULL,
  "bb_full_text" text NOT NULL,
  "html_full_text" text NOT NULL,
  "category_id" integer NOT NULL,
  -- references eshop_categories id
  "rating_points" integer NOT NULL DEFAULT 0,
  "votes_count" hstore NOT NULL DEFAULT '"p5" => "0", "p4" => "0", "p3" => "0", "p2" => "0", "p1" => "0", "m1" => "0", "m2" => "0", "m3" => "0", "m4" => "0", "m5" => "0"',
  -- p5 - addition 5, m5 - subtraction 5
  "bought_count" integer NOT NULL DEFAULT 0,
  "price" bigint NOT NULL,
  -- price -- means price per piece, in pennies
  "available_status" smallint NOT NULL DEFAULT 1,
  -- available_status -- available: 1, expecting delivery: 2, contact the manager: 3, not available: 4
  "status" smallint NOT NULL DEFAULT 2,
  --show: 1, hide: 2, deleted: 3
  "inserted_at" TIMESTAMP NOT NULL DEFAULT LOCALTIMESTAMP(0),
  "updated_at" TIMESTAMP NOT NULL DEFAULT LOCALTIMESTAMP(0),
  PRIMARY KEY ("id")
);


DROP TABLE IF EXISTS eshop_all_imgs;
CREATE TABLE "eshop_all_imgs" (
  "id" bigserial NOT NULL,
  "uid" bigint NOT NULL,
  -- references eshop_admins id
  "gid" bigint NOT NULL,
  -- references eshop_goods id
  -- gid = 0 -- other img, not for good's page
  "path" varchar(255) NOT NULL,
  -- "/2018/06/04/777" -- (date || date + (mini || micro)) and 777 - gid
  "name" varchar(255) NOT NULL,
  -- "1.jpg"
  "status" smallint NOT NULL DEFAULT 0,
  -- full_img hide: 0, full_img show: 1, preview1(mini): 2, preview2(micro) : 3
  "order" smallint NOT NULL DEFAULT 1,
  -- order for sort
  "inserted_at" TIMESTAMP NOT NULL DEFAULT LOCALTIMESTAMP(0),
  PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX eshop_all_imgs_path_name ON eshop_all_imgs (path, name);


DROP TABLE IF EXISTS eshop_categories;
CREATE TABLE "eshop_categories" (
  "id" serial NOT NULL,
  "name" varchar(255) NOT NULL,
  "path" ltree,
  "parent" integer NOT NULL DEFAULT 0,
  "status" smallint NOT NULL DEFAULT 0,
  -- status = 0 - hide, 1 - show
  "ordering" integer,
  "inserted_at" TIMESTAMP NOT NULL DEFAULT LOCALTIMESTAMP(0),
  "updated_at" TIMESTAMP NOT NULL DEFAULT LOCALTIMESTAMP(0),
  PRIMARY KEY ("id")
);

INSERT INTO "eshop_categories" (name,path,ordering) VALUES ('auto','1',10);
INSERT INTO "eshop_categories" (name,path,ordering) VALUES ('real_estate','2',20);
INSERT INTO "eshop_categories" (name,path,ordering) VALUES ('products','3',30);
INSERT INTO "eshop_categories" (name,path,ordering) VALUES ('cafes_and_restaurants','4',40);
INSERT INTO "eshop_categories" (name,path,ordering) VALUES ('entertaining_establishments','5',50);
INSERT INTO "eshop_categories" (name,path,ordering) VALUES ('supermarkets','6',60);
INSERT INTO "eshop_categories" (name,path,ordering) VALUES ('services','7',70);
INSERT INTO "eshop_categories" (name,path,ordering) VALUES ('internet_and_communication','8',80);
INSERT INTO "eshop_categories" (name,path,ordering) VALUES ('hobbies_and_sports','9',90);
INSERT INTO "eshop_categories" (name,path,ordering) VALUES ('other','10',100);

INSERT INTO "eshop_categories" (name,path,parent,ordering) VALUES ('cars','1.11',1,10);
INSERT INTO "eshop_categories" (name,path,parent,ordering) VALUES ('tss','1.12',1,20);
INSERT INTO "eshop_categories" (name,path,parent,ordering) VALUES ('arf','1.13',1,30);
INSERT INTO "eshop_categories" (name,path,parent,ordering) VALUES ('aps','1.14',1,40);

INSERT INTO "eshop_categories" (name,path,parent,ordering) VALUES ('sell','2.15',2,10);
INSERT INTO "eshop_categories" (name,path,parent,ordering) VALUES ('buy','2.16',2,20);

INSERT INTO "eshop_categories" (name,path,parent,ordering) VALUES ('shops','3.17',3,10);

INSERT INTO "eshop_categories" (name,path,parent,ordering) VALUES ('beauty_and_fashion','7.18',7,10);
INSERT INTO "eshop_categories" (name,path,parent,ordering) VALUES ('jurisprudence','7.19',7,20);
INSERT INTO "eshop_categories" (name,path,parent,ordering) VALUES ('construction_and_repair','7.20',7,30);
INSERT INTO "eshop_categories" (name,path,parent,ordering) VALUES ('other_services','7.21',7,40);



DROP TABLE IF EXISTS eshop_orders;
CREATE TABLE "eshop_orders" (
  "id" bigserial NOT NULL,
  "user_name" varchar(255) NOT NULL,
  "user_phone" varchar(255) NOT NULL,
  "user_email" varchar(255) NOT NULL,
  "user_text" varchar(255) DEFAULT NULL,
  "goods_info" hstore NOT NULL,
  -- hstore == '"id1" => "1", "name1" => "zzz", "price1" => "700", "count1" => "2", "id2" => "2", "name2" => "vvvv", "price2" => "1200", "count2" => "5"'
  -- id key && other keys concatenate id value
  -- price -- means price per piece, in pennies
  -- todo -- think about meaning to change hstore -> jsonb
  "status" smallint NOT NULL DEFAULT 1,
  --new: 1, ordered_ok: 2, deleted: 3, problem?: 4
  "inserted_at" TIMESTAMP NOT NULL DEFAULT LOCALTIMESTAMP(0),
  PRIMARY KEY ("id")
);

INSERT INTO "eshop_orders" (user_name,user_phone,user_email,user_text,goods_info) VALUES ('test1','7777777','test777@gmail.com', '7890', '"id1" => "1", "name1" => "zzz", "price1" => "700", "count1" => "2", "id2" => "2", "name2" => "vvvv", "price2" => "1200", "count2" => "5"');
INSERT INTO "eshop_orders" (user_name,user_phone,user_email,goods_info) VALUES ('test2','7777777','test777@gmail.com', '"id1" => "1", "name1" => "zzz", "price1" => "700", "count1" => "2", "id2" => "2", "name2" => "vvvv", "price2" => "1200", "count2" => "5"');







