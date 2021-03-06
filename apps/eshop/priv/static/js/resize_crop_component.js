
function resizeableImage(image_target){
  // Some variable and settings
  var $container,
  orig_src = new Image(),
  image_target = $(image_target).get(0),
  event_state = {},
  constrain = false,
  min_width = 60, // Change as required
  min_height = 60,
  max_width = 3000, // Change as required
  max_height = 2000,
  preview_max_width = 500,
  preview_max_height = 300,
  preview_width,
  preview_height,
  resize_canvas = document.createElement('canvas');
  
  resizeableImage_init();
  
  function resizeableImage_init(){
    resizeableImage_init2();
    
    // add events
    $('#preview_1_size').on('change', resizeableImage_setPreviewSize);
    $('.image_forpreview_1').on('change', resizeableImage_setImgFromForm);
    $('.preview_width_1').on('change', resizeableImage_setPreviewParamsFromForm);
    $('.preview_height_1').on('change', resizeableImage_setPreviewParamsFromForm);
    
    // Wrap the image with the container and add resize handles
    $(image_target).wrap('<div class="resize-container"></div>')
    .before('<span class="resize-handle resize-handle-nw"></span>')
    .before('<span class="resize-handle resize-handle-ne"></span>')
    .after('<span class="resize-handle resize-handle-se"></span>')
    .after('<span class="resize-handle resize-handle-sw"></span>');
    
    // Assign the container to a variable
    $container = $(image_target).parent('.resize-container');
    
    // Add events
    $container.on('mousedown touchstart', '.resize-handle', resizeableImage_startResize);
    $container.on('mousedown touchstart', 'img', resizeableImage_startMoving);
    $('.js-crop').on('click', resizeableImage_crop);
  }
  
  function resizeableImage_init2(){
    // set img from input
    //resizeableImage_setImgFromForm();
    // set preview params
    resizeableImage_setPreviewParamsFromForm();
    
    // When resizing, we will always use this copy of the original as the base
    orig_src.src = image_target.src;
  }
  
  function resizeableImage_setImgFromForm(){
    var val = $('.image_forpreview_1').val();
    if((val !== '') && (val !== 'image.jpg')){
      $(image_target).attr('src', val);
      resizeableImage_init2();
    }
  }
  
  function resizeableImage_setPreviewSize(){
    var val = $('#preview_1_size').val();
    if(val === '1'){
      document.querySelector(".preview_width_1").value = '100';
      document.querySelector(".preview_width_1").disabled = false;
      document.querySelector(".preview_height_1").value = '100';
      document.querySelector(".preview_height_1").disabled = false;
    }else if(val === '2'){
      document.querySelector(".preview_width_1").value = '70';
      document.querySelector(".preview_width_1").disabled = true;
      document.querySelector(".preview_height_1").value = '70';
      document.querySelector(".preview_height_1").disabled = true;
    }
    resizeableImage_setPreviewParamsFromForm();
  }
  
  function resizeableImage_setPreviewParamsFromForm(){
    preview_width = $('.preview_width_1').val();
    preview_height = $('.preview_height_1').val();
    if(preview_width < min_width){ preview_width = min_width; $('.preview_width_1').val(min_width); }
    if(preview_height < min_height){ preview_height = min_height; $('.preview_height_1').val(min_height); }
    if(preview_width > preview_max_width){ preview_width = preview_max_width; $('.preview_width_1').val(preview_max_width); }
    if(preview_height > preview_max_width){ preview_height = preview_max_height; $('.preview_height_1').val(preview_max_height); }
    $('.overlay').css("width", preview_width);
    $('.overlay').css("height", preview_height);
  }
  
  function resizeableImage_startResize(e){
    e.preventDefault();
    e.stopPropagation();
    resizeableImage_saveEventState(e);
    $(document).on('mousemove touchmove', resizeableImage_resizing);
    $(document).on('mouseup touchend', resizeableImage_endResize);
  }
  
  function resizeableImage_endResize(e){
    e.preventDefault();
    $(document).off('mouseup touchend', resizeableImage_endResize);
    $(document).off('mousemove touchmove', resizeableImage_resizing);
  }
  
  function resizeableImage_saveEventState(e){
    // Save the initial event details and container state
    event_state.container_width = $container.width();
    event_state.container_height = $container.height();
    event_state.container_left = $container.offset().left; 
    event_state.container_top = $container.offset().top;
    event_state.mouse_x = (e.clientX || e.pageX || e.originalEvent.touches[0].clientX) + $(window).scrollLeft(); 
    event_state.mouse_y = (e.clientY || e.pageY || e.originalEvent.touches[0].clientY) + $(window).scrollTop();
    
    // This is a fix for mobile safari
    // For some reason it does not allow a direct copy of the touches property
    if(typeof e.originalEvent.touches !== 'undefined'){
      event_state.touches = [];
      $.each(e.originalEvent.touches, function(i, ob){
        event_state.touches[i] = {};
        event_state.touches[i].clientX = 0 + ob.clientX;
        event_state.touches[i].clientY = 0 + ob.clientY;
      });
    }
    event_state.evnt = e;
  }
  
  function resizeableImage_resizing(e){
    var mouse = {}, width, height, left, top, offset = $container.offset();
    mouse.x = (e.clientX || e.pageX || e.originalEvent.touches[0].clientX) + $(window).scrollLeft(); 
    mouse.y = (e.clientY || e.pageY || e.originalEvent.touches[0].clientY) + $(window).scrollTop();
    
    // Position image differently depending on the corner dragged and constraints
    if( $(event_state.evnt.target).hasClass('resize-handle-se') ){
      width = mouse.x - event_state.container_left;
      height = mouse.y  - event_state.container_top;
      left = event_state.container_left;
      top = event_state.container_top;
    } else if($(event_state.evnt.target).hasClass('resize-handle-sw') ){
      width = event_state.container_width - (mouse.x - event_state.container_left);
      height = mouse.y  - event_state.container_top;
      left = mouse.x;
      top = event_state.container_top;
    } else if($(event_state.evnt.target).hasClass('resize-handle-nw') ){
      width = event_state.container_width - (mouse.x - event_state.container_left);
      height = event_state.container_height - (mouse.y - event_state.container_top);
      left = mouse.x;
      top = mouse.y;
      if(constrain || e.shiftKey){
        top = mouse.y - ((width / orig_src.width * orig_src.height) - height);
      }
    } else if($(event_state.evnt.target).hasClass('resize-handle-ne') ){
      width = mouse.x - event_state.container_left;
      height = event_state.container_height - (mouse.y - event_state.container_top);
      left = event_state.container_left;
      top = mouse.y;
      if(constrain || e.shiftKey){
        top = mouse.y - ((width / orig_src.width * orig_src.height) - height);
      }
    }
    
    // Optionally maintain aspect ratio
    if(constrain || e.shiftKey){
      height = width / orig_src.width * orig_src.height;
    }

    if(width > min_width && height > min_height && width < max_width && height < max_height){
      // To improve performance you might limit how often resizeImage() is called
      resizeableImage_resizeImage(width, height);  
      // Without this Firefox will not re-calculate the the image dimensions until drag end
      $container.offset({'left': left, 'top': top});
    }
    
  }
  
  function resizeableImage_resizeImage(width, height){
    resize_canvas.width = width;
    resize_canvas.height = height;
    resize_canvas.getContext('2d').drawImage(orig_src, 0, 0, width, height);   
    //$(image_target).attr('src', resize_canvas.toDataURL("image/png"));
    $(image_target).attr('src', resize_canvas.toDataURL("image/jpeg", 0.9));
  }
  
  function resizeableImage_startMoving(e){
    e.preventDefault();
    e.stopPropagation();
    resizeableImage_saveEventState(e);
    $(document).on('mousemove touchmove', resizeableImage_moving);
    $(document).on('mouseup touchend', resizeableImage_endMoving);
  }
  
  function resizeableImage_endMoving(e){
    e.preventDefault();
    $(document).off('mouseup touchend', resizeableImage_endMoving);
    $(document).off('mousemove touchmove', resizeableImage_moving);
  }
  
  function resizeableImage_moving(e){
    var mouse = {}, touches;
    e.preventDefault();
    e.stopPropagation();
    
    touches = e.originalEvent.touches;
    
    mouse.x = (e.clientX || e.pageX || touches[0].clientX) + $(window).scrollLeft(); 
    mouse.y = (e.clientY || e.pageY || touches[0].clientY) + $(window).scrollTop();
    $container.offset({
      'left': mouse.x - ( event_state.mouse_x - event_state.container_left ),
      'top': mouse.y - ( event_state.mouse_y - event_state.container_top ) 
    });
    
    // Watch for pinch zoom gesture while moving
    if(event_state.touches && event_state.touches.length > 1 && touches.length > 1){
      var width = event_state.container_width, height = event_state.container_height;
      var a = event_state.touches[0].clientX - event_state.touches[1].clientX;
      a = a * a; 
      var b = event_state.touches[0].clientY - event_state.touches[1].clientY;
      b = b * b; 
      var dist1 = Math.sqrt( a + b );
      
      a = e.originalEvent.touches[0].clientX - touches[1].clientX;
      a = a * a; 
      b = e.originalEvent.touches[0].clientY - touches[1].clientY;
      b = b * b; 
      var dist2 = Math.sqrt( a + b );

      var ratio = dist2 /dist1;

      width = width * ratio;
      height = height * ratio;
      // To improve performance you might limit how often resizeImage() is called
      resizeableImage_resizeImage(width, height);
    }
    
  }
  
  function resizeableImage_crop(){
    //Find the part of the image that is inside the crop box
    var crop_canvas,
      left = $('.overlay').offset().left - $container.offset().left,
      top =  $('.overlay').offset().top - $container.offset().top,
      width = $('.overlay').width(),
      height = $('.overlay').height();
    
    crop_canvas = document.createElement('canvas');
    crop_canvas.width = width;
    crop_canvas.height = height;
    
    crop_canvas.getContext('2d').drawImage(image_target, left, top, width, height, 0, 0, width, height);
    //window.open(crop_canvas.toDataURL("image/png"));
    //window.open(crop_canvas.toDataURL("image/jpeg", 0.9));
    
    var narr = $('.image_forpreview_1').val().split("/");
    var name = narr[narr.length - 1];
    var gid = narr[narr.length - 2];
    var day = narr[narr.length - 3];
    var month = narr[narr.length - 4];
    var year = narr[narr.length - 5];
    var pr_sz = $('#preview_1_size').val();
    if(pr_sz === '1'){ var preview_size = 'mini'; }else{ var preview_size = 'micro'; }
    
    ftp.filename = name;
    ftp.meta = utf8_toByteArray(preview_size + year + '/'+ month + '/' + day + '|' + gid);
    ftp.autostart = true;
    ftp.init(b64toBlob( crop_canvas.toDataURL("image/jpeg", 0.9), "image/jpeg" ));
  }

}

// Kick everything off with the target image
//resizeableImage($('.resize-image'));
setTimeout(function() { resizeableImage($('.resize-image')); }, 1000);


function b64toBlob(b64Data, contentType, sliceSize) {
  b64Data = b64Data.split(',')[1];
  contentType = contentType || '';
  sliceSize = sliceSize || 512;

  var byteCharacters = atob(b64Data);
  var byteArrays = [];

  for (var offset = 0; offset < byteCharacters.length; offset += sliceSize) {
    var slice = byteCharacters.slice(offset, offset + sliceSize);

    var byteNumbers = new Array(slice.length);
    for (var i = 0; i < slice.length; i++) {
      byteNumbers[i] = slice.charCodeAt(i);
    }

    var byteArray = new Uint8Array(byteNumbers);

    byteArrays.push(byteArray);
  }
    
  var blob = new Blob(byteArrays, {type: contentType});
  return blob;
}


