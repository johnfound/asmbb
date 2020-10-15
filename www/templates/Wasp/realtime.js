(function() {

    function create(node, text, styles) {
        node = document.createElement(node);
        node.innerHTML = (text != null || text != undefined) ? text : '';
        node.className = (styles != null || styles != undefined) ? styles : node.removeAttribute('class');
        return node;
    }

    function extend(source, target) {
        for(var key in target) {
            if(target.hasOwnProperty(key)) {
                source[key] = target[key];
            }
        }
        return source;
    }

    this.Toast = function(options, callback) {
        var self = this,
            config = {
                title: null,
                content: null,
                position: 'top right',
                easing: '',
                type: null,
                showProgress: false,
                timeout: 3000,
                append: false
            };

        if(options && typeof options === 'object') {
            this.o = extend(config, options);
        } else {
            this.o = config;
        }

        if(typeof callback === 'function') {
            callback.call(this, this.toast);
        }
    };

    function render() {
        var self = this;
        var c = document.querySelector('.toast-container');
        if(!c) {
            this.container = create('div', '', 'toast-container');
            document.body.appendChild(this.container);
        } else {
            this.container = c;
        }
        this.toast = create('div', '', 'toast');
        this.close = create('div', '', 'toast-close');
        var svg = [];
        svg.push('<svg viewBox="0 0 16 16">');
            svg.push('<line x1="1.5" y1="1.5" x2="14.5" y2="14.5" />');
            svg.push('<line x1="14.5" y1="1.5" x2="1.5" y2="14.5" />');
        svg.push('</svg>');
        this.close.insertAdjacentHTML('afterbegin', svg.join(' '));
        this.toast.insertAdjacentElement('afterbegin', this.close);

        var placement = '';
        this.o.append === true ? placement = 'afterbegin' : placement = 'beforeend';

        this.container.insertAdjacentElement(placement, this.toast);
        toastOptions.call(this);
    }

    function toastOptions() {
        if(this.o.position) {
            switch(this.o.position) {
                case 'top left': this.container.classList.add('top-left'); break;
                case 'top center': this.container.classList.add('top-center'); break;
                case 'top right': this.container.classList.add('top-right'); break;
                case 'bottom left': this.container.classList.add('bottom-left'); break;
                case 'bottom center': this.container.classList.add('bottom-center'); break;
                case 'bottom right': this.container.classList.add('bottom-right'); break;
                case 'left center': this.container.classList.add('left-center'); break;
                case 'center': this.container.classList.add('centered'); break;
                case 'right center': this.container.classList.add('right-center'); break;
            }
        }

        if(this.o.type) {
            switch(this.o.type) {
                case 'warning': this.toast.className += ' warning'; break;
                case 'info': this.toast.className += ' info'; break;
                case 'success': this.toast.className += ' success'; break;
                case 'caution': this.toast.className += ' caution'; break;
                case 'chat': this.toast.className += ' chat'; break;
            }
        }

        if(this.o.easing) {
            switch(this.o.easing) {
                case 'expo-in': this.toast.setAttribute('data-easing', 'expo-in'); break;
                case 'expo-out': this.toast.setAttribute('data-easing', 'expo-out'); break;
                case 'expo-in-out': this.toast.setAttribute('data-easing', 'expo-in-out'); break;
                case 'back-in': this.toast.setAttribute('data-easing', 'back-in'); break;
                case 'back-out': this.toast.setAttribute('data-easing', 'back-out'); break;
                case 'back-in-out': this.toast.setAttribute('data-easing', 'back-in-out'); break;
                case 'quart-in': this.toast.setAttribute('data-easing', 'quart-in'); break;
                case 'quart-out': this.toast.setAttribute('data-easing', 'quart-out'); break;
                case 'quart-in-out': this.toast.setAttribute('data-easing', 'quart-in-out'); break;
            }
        }

        if(this.o.title) {
            this.o.title = this.o.title;
            this.toast.appendChild(create('h4', this.o.title, 'toast-title'));
        }

        if(this.o.content) {
            if(typeof this.o.content === 'function') {
                this.o.content = this.o.content();
            } else {
                this.o.content = this.o.content;
            }
            this.toast.appendChild(create('div', this.o.content, 'toast-content'));
        }

        if(this.o.timeout) {
            if(!isNaN(this.o.timeout)) {
                toastTimeout.call(this, this.o.timeout);
            }
        }

        if(this.o.showProgress) {
            var self = this;
            this.progress = create('div', '', 'toast-progress');
            this.toast.insertAdjacentElement('beforeend', this.progress);
            this.progress.style.animation = '_progress ' + this.o.timeout + 'ms linear forwards';
        }

        if(this.o.icons) {
            this.container.classList.add('has-icons');
        }

        this.close.addEventListener('click', this.dismiss.bind(this));
    }

    function toastTimeout(time) {
        var self = this;
        if(!time) time = time;
        if(time < 1000) time = 1000;
        if(time > 300000) time = 300000;
        var timeout = setTimeout(function() {
            self.toast.classList.add('is-hiding');
            setTimeout(function() {
                self.dismiss();
            }, 1200);
        }, time);
    }

    Toast.prototype = {
        show: function() {
            render.call(this);
        },
        dismiss: function() {
            if(this.toast.parentNode || this.toast.parentNode != null) {
                this.toast.parentNode.removeChild(this.toast);
            }
        }
    };

})();


var EventSource = window.EventSource;
var source = null;
var session = '';
var TosterAlign = 'bottom right';
var ActivityTimeout = 5000;
var MessageTimeout = 15000;
var StartTime = -1;

var WantEvents = 0x0c;
var listSourceEvents = [];

var Activities = {};


function disconnect() {
  if (source) {
    source.close();
    source = null;
    Activities = {};
  }
  return null;
}


function connect() {
  var indicator  = document.getElementById("notiStroked");

  if (source) disconnect();

  if (getCookie("notificationsDisabled")) {
    indicator.style.visibility = "visible";
    return;
  }

  indicator.style.visibility = "hidden";
  source = new EventSource("/!events?events=" + WantEvents);
  StartTime = Date.now()/1000;
  listSourceEvents.forEach( function(value) { source.addEventListener(value.event, value.handler) } );
}


listSourceEvents.push(
  {
    event: 'session',
    handler:
      function(e) {
        session = e.data
      }
  }
);


listSourceEvents.push(
  {
    event: 'error',
    handler:
      function(e) {
        disconnect();
        setTimeout(connect, 2000 );
      }
  }
);


listSourceEvents.push(
  {
    event: 'user_activity',
    handler: OnActivity
  }
);



listSourceEvents.push(
  {
    event: 'message',
    handler: OnChatMessage
  }
);




function OnActivity(e) {
  var act = JSON.parse(e.data);
  if ( ! act.robot ) {
    if (Activities[act.userid] !== act.activity) {
      Activities[act.userid] = act.activity;
      var timeout = ActivityTimeout;
      if (act.type === "post") { timeout *= 10 };
      var toast = new Toast(
          {
            content: decodeURIComponent(act.activity),
            timeout: timeout,
            position: TosterAlign,
            type: 'info'
          }, 0);
      toast.show();
    }
  }
}



function createUserToaster(user, original) {
  var c = "user";
  if (user != original) {
    c += " fake_user";
  }
  return '<span class="' + c + '" title="' + original + '">' + user + '</span> ' +
  '<svg version="1.1" width="20" height="20" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg"><ellipse cx="10" cy="8" rx="10" ry="6.18"/><path d="m2.36 17v-6.52l3.82 2.54z"/></svg> ';
}



function OnChatMessage(e) {
  var msgset = JSON.parse(e.data);

  for (var i = 0; i < msgset.msgs.length; i++) {
    var msg = msgset.msgs[i];
    if ( msg.time >= StartTime) {
      var txt = '<a href="/!chat">' + createUserToaster(msg.user, msg.originalname) + replaceEmoticons(msg.text) + '</a>';

      var toast = new Toast(
          {
            content: txt,
            timeout: MessageTimeout,
            position: TosterAlign,
            type: 'chat'
          }, 0);
      toast.show();
    }
  }
}



window.addEventListener('load', connect);
window.addEventListener('beforeunload', disconnect);



// Some util functions.


function linkify(inputText) {
    var replacedText, replacePattern1;
    //URLs starting with http://, https://, or ftp://
    replacePattern1 = /(\b(https?|ftp):\/\/[-A-Z0-9+&@#\/%?=~_|!:,.;]*[-A-Z0-9+&@#\/%=~_|])/gim;
    replacedText = inputText.replace(replacePattern1, '<a class="chatlink" href="$1" target="_blank">$1</a>');
    return replacedText;
}


function replaceEmoticons(text) {
  var emoticons = {
    ':LOL:'  : ['rofl.gif', '&#x1F602;'],
    ':lol:'  : ['rofl.gif', '&#x1F602;'],
    ':ЛОЛ:'  : ['rofl.gif', '&#x1F602;'],
    ':лол:'  : ['rofl.gif', '&#x1F602;'],
    ':-)'    : ['smile.gif', '&#x1F60A;'],
    ':)'     : ['smile.gif', '&#x1F60A;'],
    ':-D'    : ['lol.gif', '&#x1F600;'],
    ':D'     : ['lol.gif', '&#x1F600;'],
    ':-Д'    : ['lol.gif', '&#x1F600;'],
    ':Д'     : ['lol.gif', '&#x1F600;'],
    '&gt;:-(': ['angry.gif', '&#x1F620;'],
    '&gt;:(' : ['angry.gif', '&#x1F620;'],
    ':-('    : ['sad.gif', '&#x1F61E;'],
    ':('     : ['sad.gif', '&#x1F61E;'],
    ':`-('   : ['cry.gif', '&#x1F62D;'],
    ':`('    : ['cry.gif', '&#x1F62D;'],
    ':\'-('  : ['cry.gif', '&#x1F62D;'],
    ':\'('   : ['cry.gif', '&#x1F62D;'],
    ';-)'    : ['wink.gif', '&#x1F609;'],
    ';)'     : ['wink.gif', '&#x1F609;'],
    ':-P'    : ['tongue.gif', '&#x1F61B;'],
    ':P'     : ['tongue.gif', '&#x1F61B;'],
    ':-П'    : ['tongue.gif', '&#x1F61B;'],
    ':П'     : ['tongue.gif', '&#x1F61B;']
  };
  var url = ActiveSkin + "/_images/chatemoticons/";
  var patterns = [];
  var metachars = /[[\]{}()*+?.\\|^$\-,&#\s]/g;

  // build a regex pattern for each defined property
  for (var i in emoticons) {
    if (emoticons.hasOwnProperty(i)) { // escape metacharacters
      patterns.push('('+i.replace(metachars, "\\$&")+')');
    }
  }

  // build the regular expression and replace
  return text.replace(new RegExp(patterns.join('|'),'g'), function (match) {
    return typeof emoticons[match] != 'undefined' ? '<img class="emo" width="20" height="20" src="'+url+emoticons[match][0]+'" alt="'+emoticons[match][1]+'">' : match;
  });
}

function formatEmoji(text) {
  var emojiRegEx = /(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])/g;
  return text.replace(emojiRegEx, '<span class="emoji"><span>$1</span></span>');
}

function switchNotificationCookie() {
  var cname = "notificationsDisabled";

  if(getCookie(cname) == "true") {
    setCookie(cname, "false", -1);
  } else {
    setCookie(cname, "true", 365);
  }

  connect();
}

function getCookie(cname) {
  var name = cname + "=";
  var decodedCookie = decodeURIComponent(document.cookie);
  var ca = decodedCookie.split(';');
  for(var i = 0; i <ca.length; i++) {
    var c = ca[i];
    while (c.charAt(0) == ' ') {
      c = c.substring(1);
    }
    if (c.indexOf(name) == 0) {
      return c.substring(name.length, c.length);
    }
  }
  return false;
}

function setCookie(cname, cvalue, exdays) {
  var d = new Date();
  d.setTime(d.getTime() + (exdays*24*60*60*1000));
  var expires = "expires="+ d.toUTCString();
  document.cookie = cname + "=" + cvalue + ";" + expires + ";path=/; SameSite=Strict; Secure;";
}
