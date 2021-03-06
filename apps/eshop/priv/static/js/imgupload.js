


'use strict';

var is_sending_file = false;
var ftp_file = undefined;

( function ( document, window, index ){
  // feature detection for drag&drop upload
  /*var isAdvancedUpload = function(){
    var div = document.createElement( 'div' );
    return ( ( 'draggable' in div ) || ( 'ondragstart' in div && 'ondrop' in div ) ) && 'FormData' in window && 'FileReader' in window;
  }();*/


  // applying the effect for every form
  // var forms = document.querySelectorAll( '.box' );
  // Array.prototype.forEach.call( forms, function( form ){
    var form = document.querySelector( '.box' ),
    input = form.querySelector( 'input[type="file"]' ),
    label     = form.querySelector( 'label' ),
    errorMsg  = form.querySelector( '.box__error span' ),
    restart   = form.querySelectorAll( '.box__restart' ),
    errorblock   = form.querySelector( '.box__error' ),
    droppedFiles = false,
    gid = false, // good's id for images
    lastfilename = '',
    
    checkAndSendFiles = function( files, i ){
      //check is sending now
      if(is_sending_file === true){
        setTimeout(checkAndSendFiles, 300, files, i);
        //console.log('we try ' + i);
        return ;
      }
      if(lastfilename !== ''){
        document.querySelector('.box__uploading').innerHTML = qs('.box__uploading').innerHTML + '<br>' + lastfilename;
      }
      if(i < files.length){
        gid = parseInt(document.querySelector('#box_images_gid').value);
        errorblock.style.display = 'none';
        errorblock.innerHTML = 'Error!';
        var maxsize = 2097152; // 2Mb in b = 2*1024*1024 = 2097152
        if(!(gid > -1)){
          errorblock.innerHTML = errorblock.innerHTML + '<br>Good&quot;s id invalid !';
          errorblock.style.display = 'block';
          return ;
        }
        var fname = files[i].name;
        lastfilename = files[i].name;
        var fnameex = fname.substr(fname.length - 4, 4);
        var fnamevalid = ((fname.split('.').length - 1) > 0) && ((fnameex === '.jpg') || (fnameex === 'jpeg') || (fnameex === 'png') );
        if((files[i].type !== 'image/jpeg') && (files[i].type !== 'image/png')){
          errorblock.innerHTML = errorblock.innerHTML + '<br>Only jpg/png filename extensions allow!<br> ' + fname + ' invalid !';
          errorblock.style.display = 'block';
          checkAndSendFiles(files, i + 1);
        }else if(files[i].size > maxsize){
          errorblock.innerHTML = errorblock.innerHTML + '<br>Only max 2Mb size allow!<br> ' + fname + ' invalid !';
          errorblock.style.display = 'block';
          checkAndSendFiles(files, i + 1);
        }else if(fnamevalid){
          //send file here
          //console.log('we send ' + fname);
          is_sending_file = true;
          document.querySelector('.box__uploading').style.display = 'block';
          
          ftp.meta = utf8_toByteArray(gid + '');
          ftp.autostart = true;
          ftp.init(files[i]);
          
          setTimeout(checkAndSendFiles, 300, files, i + 1);
          
        }else{
          errorblock.innerHTML = errorblock.innerHTML + '<br>Only jpg/png filename extensions allow!<br> ' + fname + ' invalid !';
          errorblock.style.display = 'block';
          checkAndSendFiles(files, i + 1);
        }
      }else{
        document.querySelector('.box__uploading').style.display = 'none';
        document.querySelector('.box__success').style.display = 'block';
      }
    };
    
    /*triggerFormSubmit = function(){
      var event = document.createEvent( 'HTMLEvents' );
      event.initEvent( 'submit', true, false );
      form.dispatchEvent( event );
    };*/

    /* // letting the server side to know we are going to make an Ajax request
    var ajaxFlag = document.createElement( 'input' );
    ajaxFlag.setAttribute( 'type', 'hidden' );
    ajaxFlag.setAttribute( 'name', 'ajax' );
    ajaxFlag.setAttribute( 'value', 1 );
    form.appendChild( ajaxFlag );

    // automatically submit the form on file select
    input.addEventListener( 'change', function( e ){
      checkAndSendFiles( e.target.files, 0 );
      triggerFormSubmit();
    });
    */
    
    input.addEventListener( 'change', function( e ){
      document.querySelector('.box__success').style.display = 'none';
      checkAndSendFiles( e.target.files, 0 );
    });
    
    // drag&drop files if the feature is available
    /*if( isAdvancedUpload ){*/
      form.classList.add( 'has-advanced-upload' ); // letting the CSS part to know drag&drop is supported by the browser
        
        [ 'drag', 'dragstart', 'dragend', 'dragover', 'dragenter', 'dragleave', 'drop' ].forEach( function( event ){
          form.addEventListener( event, function( e ){
            // preventing the unwanted behaviours
            e.preventDefault();
            e.stopPropagation();
          });
        });
        
        [ 'dragover', 'dragenter' ].forEach( function( event ){
          form.addEventListener( event, function(){
            form.classList.add( 'is-dragover' );
          });
        });
        
        [ 'dragleave', 'dragend', 'drop' ].forEach( function( event ){
          form.addEventListener( event, function(){
            form.classList.remove( 'is-dragover' );
          });
        });
        
        form.addEventListener( 'drop', function( e ){
          document.querySelector('.box__success').style.display = 'none';
          droppedFiles = e.dataTransfer.files; // the files that were dropped
          checkAndSendFiles( droppedFiles, 0 );
        });
    /*}*/

    // if the form was submitted
    /*form.addEventListener( 'submit', function( e ){
      // preventing the duplicate submissions if the current one is in progress
      if( form.classList.contains( 'is-uploading' ) ) return false;

      form.classList.add( 'is-uploading' );
      form.classList.remove( 'is-error' );

      // if( isAdvancedUpload ){ // ajax file upload for modern browsers
        e.preventDefault();

        // gathering the form data
        var ajaxData = new FormData( form );
        if( droppedFiles ){
          Array.prototype.forEach.call( droppedFiles, function( file ){
            ajaxData.append( input.getAttribute( 'name' ), file );
          });
        }

        // ajax request
        var ajax = new XMLHttpRequest();
        // ajax.open( form.getAttribute( 'method' ), form.getAttribute( 'action' ), true );
        ajax.open( 'POST', '/submit', true );

        ajax.onload = function(){
          form.classList.remove( 'is-uploading' );
          if( ajax.status >= 200 && ajax.status < 400 ){
            var data = JSON.parse( ajax.responseText );
            form.classList.add( data.success == true ? 'is-success' : 'is-error' );
            if( !data.success ) errorMsg.textContent = data.error;
          }else alert( 'Error. Please, contact the webmaster!' );
        };

        ajax.onerror = function(){
          form.classList.remove( 'is-uploading' );
          alert( 'Error. Please, try again!' );
        };

        ajax.send( ajaxData );
        */
      /*}else{ // fallback Ajax solution upload for older browsers
        
        var iframeName  = 'uploadiframe' + new Date().getTime(),
        iframe = document.createElement( 'iframe' );
        iframe.setAttribute( 'name', iframeName );
        iframe.style.display = 'none';

        document.body.appendChild( iframe );
        form.setAttribute( 'target', iframeName );

        iframe.addEventListener( 'load', function(){
          var data = JSON.parse( iframe.contentDocument.body.innerHTML );
          form.classList.remove( 'is-uploading' )
          form.classList.add( data.success == true ? 'is-success' : 'is-error' )
          form.removeAttribute( 'target' );
          if( !data.success ) errorMsg.textContent = data.error;
          iframe.parentNode.removeChild( iframe );
        });
      }*/
    //});

    // restart the form if has a state of error/success
    Array.prototype.forEach.call( restart, function( entry ){
      entry.addEventListener( 'click', function( e ){
        e.preventDefault();
        form.classList.remove( 'is-error', 'is-success' );
        input.click();
      });
    });

    // Firefox focus bug fix for file input
    input.addEventListener( 'focus', function(){ input.classList.add( 'has-focus' ); });
    input.addEventListener( 'blur', function(){ input.classList.remove( 'has-focus' ); });

  //});
}( document, window, 0 ));



