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
        svg.push('<svg viewBox="0 0 32 32">');
            svg.push('<line x1="0" y1="0" x2="32" y2="32" />');
            svg.push('<line x1="32" y1="0" x2="0" y2="32" />');
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
var ActivityAlign = 'bottom right';
var ActivityTimeout = 10000;

var WantEvents = 8;
var listSourceEvents = [];


function disconnect() {
  source.close();
  source = null;
  return null;
}


function connect() {
  if (source) disconnect();
  source = new EventSource("/!events?events=" + WantEvents);
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


function OnActivity(e) {
  var act = JSON.parse(e.data);
  if ( ! act.robot ) {
    var toast = new Toast(
        {
          content: decodeURIComponent(act.activity),
          timeout: ActivityTimeout,
          position: ActivityAlign,
          type: 'info'
        }, 0);
    toast.show();
  }
}


listSourceEvents.push(
  {
    event: 'user_activity',
    handler: OnActivity
  }
);


window.addEventListener('load', connect);
window.addEventListener('beforeunload', disconnect);

