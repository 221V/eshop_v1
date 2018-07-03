-module(tr).
-compile([export_all, nowarn_export_all]).

%translations module

% "system" words
tr(_, project_name, _) -> <<"Eshop">>;


% translations
%tr(<<"en">>, test, <<"lang">>) -> <<"English">>;
tr(<<"en">>, main, <<"main">>) -> <<"Main">>;
tr(<<"en">>, main, <<"catalog">>) -> <<"Catalog">>;
tr(<<"en">>, main, <<"brand">>) -> <<"Eshop">>;
tr(<<"en">>, main, <<"cart">>) -> <<"Cart">>;
tr(<<"en">>, main, <<"cart_title">>) -> <<"Your cart">>;
tr(<<"en">>, main, <<"close">>) -> <<"Close">>;
tr(<<"en">>, main, <<"order_now">>) -> <<"Order now">>;
tr(<<"en">>, main, <<"load_more_goods">>) -> <<"Load more goods">>;
tr(<<"en">>, main, <<"load_more_goods1">>) -> <<"Load">>;
tr(<<"en">>, main, <<"load_more_goods2">>) -> <<"more goods">>;
tr(<<"en">>, main, <<"success">>) -> <<"Success">>;
tr(<<"en">>, main_goods, <<"rating">>) -> <<"Rating">>;
tr(<<"en">>, main_goods, <<"no_data">>) -> <<"No data">>;
tr(<<"en">>, main_goods, <<"details">>) -> <<"Details">>;
tr(<<"en">>, main_goods, <<"add_to_cart">>) -> <<"Add to Cart">>;
tr(<<"en">>, goods_sort, <<"by_rating">>) -> <<"Sort by rating">>;
tr(<<"en">>, goods_sort, <<"by_cheap">>) -> <<"Cheapest first">>;
tr(<<"en">>, goods_sort, <<"by_expensive">>) -> <<"Most expensive first">>;
tr(<<"en">>, main_goods, <<"status_delivery">>) -> <<"expecting delivery">>;
tr(<<"en">>, main_goods, <<"status_contact_manager">>) -> <<"contact the manager">>;
tr(<<"en">>, main_goods, <<"status_not_available">>) -> <<"not available">>;

tr(<<"en">>, category, <<"active_category">>) -> <<"Active Category">>;
tr(<<"en">>, category, <<"sub_categories">>) -> <<"SubCategories">>;
tr(<<"en">>, goods, <<"category_text">>) -> <<"Category">>;

tr(<<"en">>, js, <<"price">>) -> <<"price">>;
tr(<<"en">>, js, <<"total">>) -> <<"total">>;
tr(<<"en">>, js, <<"total_price">>) -> <<"Total price">>;
tr(<<"en">>, js, <<"fill_form">>) -> <<"Please fill the form">>;

tr(<<"en">>, cart, <<"no_items">>) -> <<"No items">>;
tr(<<"en">>, cart, <<"your_name">>) -> <<"Your name">>;
tr(<<"en">>, cart, <<"your_email">>) -> <<"Your email">>;
tr(<<"en">>, cart, <<"your_phone">>) -> <<"Your phone number">>;
tr(<<"en">>, cart, <<"your_comment">>) -> <<"Comment (optional)">>;



%tr(<<"ru">>, test, <<"lang">>) -> <<"Русский"/utf8>>;



%tr(<<"uk">>, test, <<"lang">>) -> <<"Українська"/utf8>>;
tr(<<"uk">>, main, <<"main">>) -> <<"Головна"/utf8>>;
tr(<<"uk">>, main, <<"catalog">>) -> <<"Каталог"/utf8>>;
tr(<<"uk">>, main, <<"brand">>) -> <<"Eshop"/utf8>>;
tr(<<"uk">>, main, <<"cart">>) -> <<"Кошик"/utf8>>;
tr(<<"uk">>, main, <<"cart_title">>) -> <<"Ваш кошик"/utf8>>;
tr(<<"uk">>, main, <<"close">>) -> <<"Закрити"/utf8>>;
tr(<<"uk">>, main, <<"order_now">>) -> <<"Замовити"/utf8>>;
tr(<<"uk">>, main, <<"load_more_goods">>) -> <<"Підзавантажити більше товарів"/utf8>>;
tr(<<"uk">>, main, <<"load_more_goods1">>) -> <<"Підзавантажити ще"/utf8>>;
tr(<<"uk">>, main, <<"load_more_goods2">>) -> <<"товарів"/utf8>>;
tr(<<"uk">>, main, <<"success">>) -> <<"Успішно"/utf8>>;
tr(<<"uk">>, main_goods, <<"rating">>) -> <<"Рейтинг"/utf8>>;
tr(<<"uk">>, main_goods, <<"no_data">>) -> <<"Дані відсутні"/utf8>>;
tr(<<"uk">>, main_goods, <<"details">>) -> <<"Детальніше"/utf8>>;
tr(<<"uk">>, main_goods, <<"add_to_cart">>) -> <<"Додати в кошик"/utf8>>;
tr(<<"uk">>, goods_sort, <<"by_rating">>) -> <<"Сортування за рейтингом"/utf8>>;
tr(<<"uk">>, goods_sort, <<"by_cheap">>) -> <<"Спочатку дешевші"/utf8>>;
tr(<<"uk">>, goods_sort, <<"by_expensive">>) -> <<"Спочатку дорожчі"/utf8>>;
tr(<<"uk">>, main_goods, <<"status_delivery">>) -> <<"очікується поставка"/utf8>>;
tr(<<"uk">>, main_goods, <<"status_contact_manager">>) -> <<"зв&qout;яжіться з менеджером"/utf8>>;
tr(<<"uk">>, main_goods, <<"status_not_available">>) -> <<"немає в наявності"/utf8>>;

tr(<<"uk">>, category, <<"active_category">>) -> <<"Активна категорія"/utf8>>;
tr(<<"uk">>, category, <<"sub_categories">>) -> <<"СубКатегорії"/utf8>>;
tr(<<"uk">>, goods, <<"category_text">>) -> <<"Категорія"/utf8>>;

tr(<<"uk">>, js, <<"price">>) -> <<"ціна"/utf8>>;
tr(<<"uk">>, js, <<"total">>) -> <<"загалом"/utf8>>;
tr(<<"uk">>, js, <<"total_price">>) -> <<"Загальна сума"/utf8>>;
tr(<<"uk">>, js, <<"fill_form">>) -> <<"Будь-ласка заповніть форму"/utf8>>;

tr(<<"uk">>, cart, <<"no_items">>) -> <<"Ваш кошик пустий"/utf8>>;
tr(<<"uk">>, cart, <<"your_name">>) -> <<"Ваше ім&quot;я"/utf8>>;
tr(<<"uk">>, cart, <<"your_email">>) -> <<"Ваш Email"/utf8>>;
tr(<<"uk">>, cart, <<"your_phone">>) -> <<"Ваш номер телефону"/utf8>>;
tr(<<"uk">>, cart, <<"your_comment">>) -> <<"Коментар (опціонально)"/utf8>>;


%tr(_, _, _) -> <<"">>.
tr(_, _, A) -> A.

