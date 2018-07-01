
function cart_good_incr(e){
  var el = e.target;
  var ngcountel = el.previousSibling;
  var ngcount = +(ngcountel.value);
  
  if(ngcount > 0){
    ngcount++;
  }else{
    ngcount = 1;
  }
  ngcountel.value = ngcount;
  var good = ngcountel.parentNode.parentNode;
  var id = good.dataset.id;
  var price = good.dataset.price;
  updatecount_item2localStorage([id,'',ngcount,price]);
  cart_good_calc_price(false,ngcountel.parentNode);
}


function cart_good_decr(e){
  var el = e.target;
  var ngcountel = el.nextSibling;
  var ngcount = +(ngcountel.value);
  
  if(ngcount > 2){
    ngcount--;
  }else{
    ngcount = 1;
  }
  ngcountel.value = ngcount;
  var good = ngcountel.parentNode.parentNode;
  var id = good.dataset.id;
  var price = good.dataset.price;
  updatecount_item2localStorage([id,'',ngcount,price]);
  cart_good_calc_price(false,ngcountel.parentNode);
}


function cart_good_calc_price(e,par){
  /* recalc one */
  if(!par){
  var par = e.target.parentNode;
  }
  
  var par0 = par.parentNode;
  var nprice = +(par0.dataset.price);
  var ngcount = +(par.querySelector('.cartgoodscount').value);
  
  var res = '$ ' + ((nprice * ngcount) / 100) + '';
  var goodtotalel = par.querySelector('.goodtotal');
  goodtotalel.innerHTML = res;
  
  cart_goods_recalc_prices();
}


function cart_goods_recalc_prices(){
  /* recalc all */
  window.cart_total = 0;
  var cart_goods = document.querySelectorAll('.cartgood');
  cart_goods.forEach(function(n){
    var nprice = +(n.dataset.price);
    var ngcount = +(n.querySelector('.cartgoodscount').value);
    n.querySelector('.goodtotal').innerHTML = '$ ' + (ngcount * nprice / 100) + '';
    window.cart_total = window.cart_total + (nprice * ngcount);
  });
  
  var tot = document.querySelector('.carttotal');
  if(tot){
    var res = '$ ' + (window.cart_total / 100) + '';
    tot.innerHTML = res;
  }else{
    document.querySelector('#CartModal').querySelector('.modal-body').innerHTML = 'No items';
  }
}


function cart_good_bind(){
  /* bind all */
  var cart_goods = document.querySelectorAll('.cartgood');
  cart_goods.forEach(function(n){
    /*var nprice = +(n.dataset.price);*/
    var n2 = n.childNodes[1];
    /*var total = n2.querySelector('.goodtotal');*/
    var decr = n2.querySelector('.cartgooddecr');
    var incr = n2.querySelector('.cartgoodincr');
    var del = n2.querySelector('.deletegood');
    var ngcount = n2.querySelector('.cartgoodscount');
    
    incr.addEventListener("click", cart_good_incr, false);
    decr.addEventListener("click", cart_good_decr, false);
    del.addEventListener("click", cart_good_del, false);
    ngcount.addEventListener("change", cart_good_calc_price, false);
    
  });
}


function cart_good_unbind(el){
  /* unbind one */
  var decr = el.querySelector('.cartgooddecr');
  var incr = el.querySelector('.cartgoodincr');
  var del = el.querySelector('.deletegood');
  var ngcount = el.querySelector('.cartgoodscount');
  incr.removeEventListener("click", cart_good_incr, false);
  decr.removeEventListener("click", cart_good_decr, false);
  del.removeEventListener("click", cart_good_del, false);
  ngcount.removeEventListener("change", cart_good_calc_price, false);
}


function cart_good_del(e){
  var el = e.target;
  var id = el.parentNode.parentNode.dataset.id;
  del_oneitemlocalStorage(id);
  
  var par = el.parentNode;
  var par2 = par.parentNode;
  var hr = par2.nextSibling.nextSibling;
  
  cart_good_unbind(par);
  
  par2.remove();
  hr.remove();
  
  items2cart();
  cart_goods_recalc_prices();
}


function found_and_select(el,val){
  var opts = el.getElementsByTagName('option');
  for(var i=0;i<opts.length;i++){
    if(opts[i].value == val){
      opts[i].selected = 'selected';break;
    }
  }
}


function sorting_bind(){
  var el = qi('goodssorting');
  el.addEventListener("change", function(){
    window.sort_type = parseInt(el.value);
    qi('loadmorebtn').style.display='none';
    /*var all_count = window.goodsallcount;
    var loaded = window.goodsloaded;*/
    var cat_id = window.cat_id;
    var sort_type = window.sort_type;
    if(cat_id == undefined){cat_id = 0;}
    var timerId = setTimeout(function tick(){
      if(window.active){
        if(window.load_first_wait !== true){
          window.load_first_wait = true;
          ws.send(enc(tuple( atom('client'), tuple(atom('load_first'), number(cat_id), number(sort_type) ) )));
        }
      }else{
        timerId = setTimeout(tick, 200);
      }
      }, 100);
  });
}


function add_item2localStorage(it){
  var local = localStorage.getItem("cart");
  if((local !== null) && (local !== "null") && (local !== "[]")){
    // not first item in cart
    var added = false;
    var newarr = [];
    var arr = JSON.parse(local);
    arr.forEach(function(el){
      var id = el[0];
      var name = el[1];
      var count = el[2];
      var price = el[3];
      
      if(id === it[0]){
        newarr.push([id, name, count + 1, price]);
        added = true;
      }else{
        newarr.push(el);
      }
    });
    if(added === false){ newarr.push(it); }
    localStorage.setItem("cart",JSON.stringify(newarr));
  }else{
    // first item in cart
    localStorage.setItem("cart",JSON.stringify([it]));
  }
}

function updatecount_item2localStorage(it){
  var local = localStorage.getItem("cart");
  if((local !== null) && (local !== "null") && (local !== "[]")){
    var newarr = [];
    var arr = JSON.parse(local);
    arr.forEach(function(el){
      var id = el[0];
      var name = el[1];
      var count = el[2];
      var price = el[3];
      
      if(id === it[0]){
        newarr.push([id, name, it[2], it[3]]);
        added = true;
      }else{
        newarr.push(el);
      }
    });
    localStorage.setItem("cart",JSON.stringify(newarr));
  }
}

function del_allitemslocalStorage(){
  localStorage.setItem("cart",null);
}

function del_oneitemlocalStorage(id){
  var local = localStorage.getItem("cart");
  if((local !== null) && (local !== "null")){
    // we have items
    var arr = JSON.parse(local);
    var result = [];
    arr.forEach(function(el){
      if(el[0] != id){ result.push(el); }
    });
    localStorage.setItem("cart",JSON.stringify(result));
  }
}


function items2cart(){
  var local = localStorage.getItem("cart");
  if((local !== null) && (local !== "null") && (local !== "[]")){
    // we have items
    var arr = JSON.parse(local);
    var result = '';
    arr.forEach(function(el){
      var id = el[0];
      var name = el[1];
      var count = el[2];
      var price = el[3];
      var price2 = '$ ' + (price/100) + '';
      
      //result = result + '<div class="cartgood" data-id="' + id + '" data-price="' + price + '"><p><img alt="' + name + '" style="width: 60px; height: 60px;" src="#"><span>' + name + '</span></p><p><button type="button" class="cartgooddecr btn btn-outline-primary">-</button><input class="cartgoodscount" type="number" min="1" step="1" value="' + count + '"><button type="button" class="cartgoodincr btn btn-outline-primary">+</button><span class="goodtotalbl">price ' + price2 + '<br>total <span class="goodtotal">$</span></span><button type="button" class="deletegood btn btn-outline-danger">X</button></p></div><hr class="style16">';
      //micro-img add later
      result = result + '<div class="cartgood" data-id="' + id + '" data-price="' + price + '"><p><span><a href="/goods/?id=' + id + '" target="_blank">' + name + '</a></span></p><p><button type="button" class="cartgooddecr btn btn-outline-primary">-</button><input class="cartgoodscount" type="number" min="1" step="1" value="' + count + '"><button type="button" class="cartgoodincr btn btn-outline-primary">+</button><span class="goodtotalbl">price ' + price2 + '<br>total <span class="goodtotal">$</span></span><button type="button" class="deletegood btn btn-outline-danger">X</button></p></div><hr class="style16">';
    });
    if(result !== ''){
      result = result + '<p class="carttotalbl"><span>Total price <span class="carttotal">$</span></span></p><hr class="style16">';
      if(qi('cartpage')){
        qi('cartpagegoods').innerHTML = result;
        cart_good_bind();
        cart_goods_recalc_prices();
      }else{
        document.querySelector('#CartModal').querySelector('.modal-body').innerHTML = result;
        cart_good_bind();
        cart_goods_recalc_prices();
        qi('ordernow').style.display='block';
        qi('cart_userinfo').style.display='block';
      }
    }
  }else{
    // no items
    if(qi('cartpage')){
      qi('cartpagegoods').innerHTML = 'No items';
    }else{
      document.querySelector('#CartModal').querySelector('.modal-body').innerHTML = 'No items';
    }
    qi('ordernow').style.display='none';
    qi('cart_userinfo').style.display='none';
  }
}


function bind_goods2cart(){
  var items = document.querySelectorAll('.add2cart');
  items.forEach(function(el){
    el.addEventListener("click", function(){
      var id = el.dataset.id;
      var price = el.dataset.price;
      if(document.querySelector('.goodpage-title')){
        var name = document.querySelector('.goodpage-title').innerText;
      }else{
        var name = el.parentNode.previousSibling.previousSibling.childNodes[0].innerText;
      }
      add_item2localStorage([id,name,1,price]);
      if(document.querySelector('#CartModal')){
      items2cart();
      }
      var btn = this;
      btn.style.display = 'none';
    });
  });
}


function bind_cart_ordernow(){
  qi('ordernow').addEventListener("click", function(){
    var name = qi('cart_user_name').value;
    var name_valid = (name !== '');
    var email = qi('cart_user_email').value;
    var email_valid = (email !== '');
    var phone = qi('cart_user_phone').value;
    var phone_valid = (phone !== '');
    var text = qi('cart_user_comment').value;
    
    if(name_valid && email_valid && phone_valid){
      
      var result = '';
      var cart_goods = document.querySelectorAll('.cartgood');
      cart_goods.forEach(function(n){
        var id = +(n.dataset.id);
        var count = +(n.querySelector('.cartgoodscount').value);
        if(result === ''){result = id + ',' + count;}else{
        result = result + ',' + id + ',' + count ;}
      });
      
      var timerId = setTimeout(function tick(){
      if(window.active){
        if(window.sendord_wait !== true){
          window.sendord_wait = true;
          ws.send(enc(tuple( atom('client'), tuple(atom('new_order'), bin(name), bin(phone), bin(email), bin(text), bin(result) ) )));
        }
      }else{
        timerId = setTimeout(tick, 200);
      }
      }, 100);
    }else{
      alert('Please fill the form !');
    }
  });
}


function bind_load_more(){
  qi('loadmorebtn').addEventListener("click", function(){
    qi('loadmorebtn').style.display='none';
    var all_count = window.goodsallcount;
    var loaded = window.goodsloaded;
    var cat_id = window.cat_id;
    var sort_type = window.sort_type;
    if(cat_id == undefined){cat_id = 0;}
    var timerId = setTimeout(function tick(){
      if(window.active){
        if(window.load_more_wait !== true){
          window.load_more_wait = true;
          ws.send(enc(tuple( atom('client'), tuple(atom('load_more'), number(all_count), number(loaded), number(cat_id), number(sort_type) ) )));
        }
      }else{
        timerId = setTimeout(tick, 200);
      }
      }, 100);
  });
}


window.addEventListener("load", function(){
  if(qi('goodssorting')){
    sorting_bind();
    var lightbox = new Lightbox();
    lightbox.load();
  }
  if(document.querySelector('.goodpage-title')){
    var lightbox = new Lightbox();
    lightbox.load();
  }
  if(document.querySelector('.add2cart')){
    bind_goods2cart();
  }
  if(qi('ordernow')){
    bind_cart_ordernow();
  }
  if(document.querySelector('#CartModal')){
  items2cart();
  }
  if(qi('cartpage')){
  items2cart();
  }
  if(qi('no_goods_here')){
  qi('goodssorting').style.display='none';
  qi('loadmorebtn').style.display='none';
  }
  cart_good_bind();
  
});


