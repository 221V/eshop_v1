

function do_login_bind(){
  qi('do_login').addEventListener("click", function(){
    var l = qi('login').value;
    var p = qi('pass').value;
    if((l != '') && (p != '')){
      var timerId = setTimeout(function tick(){
      if(window.active){
        window.login_wait = true;
        ws.send(enc(tuple( atom('client'), tuple(atom('login'), utf8_toByteArray(l), utf8_toByteArray(p) ) )));
      }else{
        timerId = setTimeout(tick, 200);
      }
      }, 100);
    }else{
    alert('login or pass can\'t be empty string !');
    }
  });
}


function textareas_init(){
  textarea_preview_good = qi('bb_preview_good');
  sceditor.create(textarea_preview_good, {
  format: 'bbcode',
  icons: 'monocons',
  style: '/css/sceditor-default.min.css'
  });
  textarea_good = qi('bb_full_good');
  sceditor.create(textarea_good, {
  format: 'bbcode',
  icons: 'monocons',
  style: '/css/sceditor-default.min.css'
  });
}


function do_addgood_bind(){
  qi('good_add_new').addEventListener("click", function(){
    var cat = parseInt(qi('cat_id').value);
    var cat_valid = Number.isInteger(cat);
    var title = qi('good_title').value;
    var title_valid = (title !== '');
    var title_img = qi('good_img_title').value;
    var title_img_valid = (title_img !== '');
    var preview_good = sceditor.instance(textarea_preview_good).getWysiwygEditorValue();
    var full_good = sceditor.instance(textarea_good).getWysiwygEditorValue();
    var preview_good_valid = (preview_good !== '');
    var full_good_valid = (full_good !== '');
    var good_price = qi('good_price').value;
    var re1 = /^[1-9]{1}[0-9]*$/i;
    var good_price_valid = re1.test(good_price);
    good_price = parseInt(good_price);
    var good_available_status = parseInt(qi('good_available_status').value);
    var good_available_status_valid = (good_available_status === 1) || (good_available_status === 2) || (good_available_status === 3) || (good_available_status === 4);
    var good_status = parseInt(qi('good_status').value);
    var good_status_valid = (good_status === 1) || (good_status === 2);
    
    var valid_all = cat_valid && title_valid && title_img_valid && preview_good_valid && full_good_valid && good_price_valid && good_available_status_valid && good_status_valid;
    if(valid_all){
      var timerId = setTimeout(function tick(){
      if(window.active){
        if(window.send_wait !== true){
          window.send_wait = true;
          ws.send(enc(tuple( atom('client'), tuple(atom('new_good'), number(cat), utf8_toByteArray(title), utf8_toByteArray(title_img), utf8_toByteArray(preview_good), utf8_toByteArray(full_good), number(good_price), number(good_available_status), number(good_status) ) )));
        }
      }else{
        timerId = setTimeout(tick, 200);
      }
      }, 100);
    }else{
      alert('invalid data !');
    };
  });
}


function do_editgood_bind(){
  qi('good_changes_save').addEventListener("click", function(){
    var cat = parseInt(qi('cat_id').value);
    var cat_valid = Number.isInteger(cat);
    var title = qi('good_title').value;
    var title_valid = (title !== '');
    var title_img = qi('good_img_title').value;
    var title_img_valid = (title_img !== '');
    var preview_good = sceditor.instance(textarea_preview_good).getWysiwygEditorValue();
    var full_good = sceditor.instance(textarea_good).getWysiwygEditorValue();
    var preview_good_valid = (preview_good !== '');
    var full_good_valid = (full_good !== '');
    var good_price = qi('good_price').value;
    var re1 = /^[1-9]{1}[0-9]*$/i;
    var good_price_valid = re1.test(good_price);
    good_price = parseInt(good_price);
    var good_available_status = parseInt(qi('good_available_status').value);
    var good_available_status_valid = (good_available_status === 1) || (good_available_status === 2) || (good_available_status === 3) || (good_available_status === 4);
    var good_status = parseInt(qi('good_status').value);
    var good_status_valid = (good_status === 1) || (good_status === 2);
    
    var valid_all = cat_valid && title_valid && title_img_valid && preview_good_valid && full_good_valid && good_price_valid && good_available_status_valid && good_status_valid;
    if(valid_all){
      var timerId = setTimeout(function tick(){
      if(window.active){
        if(window.send_wait !== true){
          window.send_wait = true;
          ws.send(enc(tuple( atom('client'), tuple(atom('update_good'), number(cat), utf8_toByteArray(title), utf8_toByteArray(title_img), utf8_toByteArray(preview_good), utf8_toByteArray(full_good), number(good_price), number(good_available_status), number(good_status) ) )));
        }
      }else{
        timerId = setTimeout(tick, 200);
      }
      }, 100);
    }else{
      alert('invalid data !');
    };
  });
}


function do_edithtml_good_bind(){
  qi('good_changes_save').addEventListener("click", function(){
    var cat = parseInt(qi('cat_id').value);
    var cat_valid = Number.isInteger(cat);
    var title = qi('good_title').value;
    var title_valid = (title !== '');
    var title_img = qi('good_img_title').value;
    var title_img_valid = (title_img !== '');
    var preview_good = qi('html_preview_good').value;
    var full_good = qi('html_good').value;
    var preview_good_valid = (preview_good !== '');
    var full_good_valid = (full_good !== '');
    var good_price = qi('good_price').value;
    var re1 = /^[1-9]{1}[0-9]*$/i;
    var good_price_valid = re1.test(good_price);
    good_price = parseInt(good_price);
    var good_available_status = parseInt(qi('good_available_status').value);
    var good_available_status_valid = (good_available_status === 1) || (good_available_status === 2) || (good_available_status === 3) || (good_available_status === 4);
    var good_status = parseInt(qi('good_status').value);
    var good_status_valid = (good_status === 1) || (good_status === 2);
    
    var valid_all = cat_valid && title_valid && title_img_valid && preview_good_valid && full_good_valid && good_price_valid && good_available_status_valid && good_status_valid;
    if(valid_all){
      var timerId = setTimeout(function tick(){
      if(window.active){
        if(window.send_wait !== true){
          window.send_wait = true;
          ws.send(enc(tuple( atom('client'), tuple(atom('update_html_good'), number(cat), utf8_toByteArray(title), utf8_toByteArray(title_img), utf8_toByteArray(preview_good), utf8_toByteArray(full_good), number(good_price), number(good_available_status), number(good_status) ) )));
        }
      }else{
        timerId = setTimeout(tick, 200);
      }
      }, 100);
    }else{
      alert('invalid data !');
    };
  });
}


function bind_show_gidimg(){
  qi('goto_gidimg').addEventListener("click", function(){
    var gid = parseInt(qi('gidimg').value);
    if(Number.isInteger(gid) && ((gid === 0) || (gid > 0))){
      window.location.href = window.location.href + '?gid=' + gid;
    }else{
      alert('invalid good id !');
    }
  });
}


function found_and_select(el,val){
  var opts = el.getElementsByTagName('option');
  for(var i=0;i<opts.length;i++){
    if(opts[i].value == val){
      opts[i].selected = 'selected';break;
    }
  }
}


function change_img_status(id, val){
  var val = parseInt(val);
  var valid = Number.isInteger(id) && (id > 0) && ((val === 0) || (val === 1));
  if(valid){
    var timerId = setTimeout(function tick(){
      if(window.active){
        if(window.updstatus_wait !== true){
          window.updstatus_wait = true;
          ws.send(enc(tuple( atom('client'), tuple(atom('update_status'), number(id), number(val) ) )));
        }
      }else{
        timerId = setTimeout(tick, 200);
      }
    }, 100);
  }else{
  alert('error data !');
  }
}


function change_img_order(id, val){
  var val = parseInt(val);
  var valid = Number.isInteger(id) && (id > 0) && (val > 0);
  if(valid){
    var timerId = setTimeout(function tick(){
      if(window.active){
        if(window.updorder_wait !== true){
          window.updorder_wait = true;
          ws.send(enc(tuple( atom('client'), tuple(atom('update_order'), number(id), number(val) ) )));
        }
      }else{
        timerId = setTimeout(tick, 200);
      }
    }, 100);
  }else{
  alert('error data !');
  }
}


function upd_category_name(el,id){
  var old_name = el.previousSibling.previousSibling.innerHTML;
  var new_name = prompt('New name for category: \'' + old_name + '\'', old_name);
  if(new_name === null){}else{
    var timerId = setTimeout(function tick(){
      if(window.active){
        if(window.updname_wait !== true){
          window.updname_wait = true;
          ws.send(enc(tuple( atom('client'), tuple(atom('update_name'), number(id), bin(new_name) ) )));
        }
      }else{
        timerId = setTimeout(tick, 200);
      }
    }, 100);
  }
}


function upd_category_status(el,id){
  var id_valid = Number.isInteger(id) && (id > 0);
  var val = parseInt(el.value);
  var val_valid = Number.isInteger(val) && ((val == 0) || (val == 1));
  if(id_valid && val_valid){
    var timerId = setTimeout(function tick(){
      if(window.active){
        if(window.catstatus_wait !== true){
          window.catstatus_wait = true;
            ws.send(enc(tuple( atom('client'), tuple(atom('change_status'), number(id), number(val) ) )));
        }
      }else{
        timerId = setTimeout(tick, 200);
      }
    }, 100);
  }
}


function move_category(el,id){
  var valid = Number.isInteger(id) && (id > 0);
  if(valid){
    var name = el.previousSibling.previousSibling.previousSibling.previousSibling.innerHTML;
    var new_parent = prompt('New parent id for category: \'' + name + '\'', '');
    if(new_parent === null){}else{
      new_parent = parseInt(new_parent);
      var valid_parent = Number.isInteger(new_parent) && (new_parent > 0);
      if(valid_parent){
        var timerId = setTimeout(function tick(){
          if(window.active){
            if(window.movecat_wait !== true){
              window.movecat_wait = true;
              ws.send(enc(tuple( atom('client'), tuple(atom('move_category'), number(id), number(new_parent) ) )));
            }
          }else{
            timerId = setTimeout(tick, 200);
          }
        }, 100);
      }
    }
  }else{
    alert('invalid data !');
  }
}


function new_category(el){
  el = el.parentNode.querySelector('#new_category_name');
  var val = el.value;
  if(val != ''){
    var timerId = setTimeout(function tick(){
      if(window.active){
        if(window.newname_wait !== true){
          window.newname_wait = true;
          ws.send(enc(tuple( atom('client'), tuple(atom('new_category'), bin(val) ) )));
        }
      }else{
        timerId = setTimeout(tick, 200);
      }
    }, 100);
  }else{
  alert('invalid data !');
  }
}


function update_category_order(el,id){
  var val = el.parentNode.querySelector('.category_order').value;
  val = parseInt(val);
  var valid = Number.isInteger(id) && (id > 0) && Number.isInteger(val) && (val >= 0);
  if(valid){
    var timerId = setTimeout(function tick(){
      if(window.active){
        if(window.updorder_wait !== true){
          window.updorder_wait = true;
          ws.send(enc(tuple( atom('client'), tuple(atom('update_order'), number(id), number(val) ) )));
        }
      }else{
        timerId = setTimeout(tick, 200);
      }
    }, 100);
  }else{
    alert('invalid data !');
  }
}


function goto_goodid(p){
  var val = qi('goto_gid').value;
  val = parseInt(val);
  var val_valid = Number.isInteger(val) && (val > 0);
  if(val_valid){
    if(p == 1){ window.location.href = '/adminka/goods/edit/?gid=' + val + ''; }
    if(p == 2){ window.location.href = '/adminka/goods/edit_html/?gid=' + val + ''; }
    if(p == 3){ window.location.href = '/adminka/images/gid_all/?gid=' + val + ''; }
  }else{
    alert('invalid good\'s id !');
  }
}


function goto_orderid(){
  var val = qi('goto_oid').value;
  val = parseInt(val);
  var val_valid = Number.isInteger(val) && (val > 0);
  if(val_valid){
    window.location.href = '/adminka/order_by_id/?id=' + val + '';
  }else{
    alert('invalid order\'s id !');
  }
}


function change_order_status(el){
  var id = parseInt(el.dataset.id);
  var val = parseInt(el.value);
  var valid = Number.isInteger(id) && (id > 0) && Number.isInteger(val) && (val > 0);
  if(valid){
    var timerId = setTimeout(function tick(){
      if(window.active){
        if(window.updstatus_wait !== true){
          window.updstatus_wait = true;
          ws.send(enc(tuple( atom('client'), tuple(atom('update_status'), number(id), number(val) ) )));
        }
      }else{
        timerId = setTimeout(tick, 200);
      }
    }, 100);
  }else{
    alert('invalid data !')
  }
}


function logout(){
  var timerId = setTimeout(function tick(){
    if(window.logouting !== true){
    if(window.active){
      window.logouting = true;
      ws.send(enc(tuple( atom('client'), tuple(atom('logout') ) )));
    }else{
      timerId = setTimeout(tick, 200);
    }
    }
  }, 100);
}


window.addEventListener("load", function load(e0){
  if(qi('do_logout')){
  qi('do_logout').addEventListener("click", logout, false);
  }
  
},false);


