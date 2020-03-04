[css:navigation.css]
[css:posts.css]
[css:markdown.css]

[case:[special:lang]|
  [equ:btnCats=Categories]
  [equ:btnList=Threads]
  [equ:btnNewPost=Answer]
  [equ:btnSettings=Settings]
  [equ:btnConsole=SQL console]
  [equ:ttlEditThread=Edit the thread attributes.]
  [equ:rssfeed=Subscribe to this thread]
|
  [equ:btnCats=Категории]
  [equ:btnList=Теми]
  [equ:btnNewPost=Отговор]
  [equ:btnSettings=Настройки]
  [equ:btnConsole=SQL конзола]
  [equ:ttlEditThread=Редактиране на атрибутите на темата.]
  [equ:rssfeed=Абонирай се за тази тема]
|
  [equ:btnCats=Категории]
  [equ:btnList=Темы]
  [equ:btnNewPost=Ответить]
  [equ:btnSettings=Настройки]
  [equ:btnConsole=SQL конзоль]
  [equ:ttlEditThread=Редакция атрибутов темы]
  [equ:rssfeed=Подпишитесь на эту тему]
|
  [equ:btnCats=Catégories]
  [equ:btnList=Liste des sujets]
  [equ:btnNewPost=Répondre]
  [equ:btnSettings=Paramètres]
  [equ:btnConsole=Console SQL]
  [equ:ttlEditThread=Éditer le titre du sujet et les mots-clés.]
  [equ:rssfeed=Suivre ce sujet]
|
  [equ:btnCats=Kategorien]
  [equ:btnList=Themen]
  [equ:btnNewPost=Antworten]
  [equ:btnSettings=Einstellungen]
  [equ:btnConsole=SQL-Konsole]
  [equ:ttlEditThread=Themenoptionen ändern.]
  [equ:rssfeed=Dieses Thema abonnieren]
]

<div class="ui">
  <a class="btn left" href="/!categories">[const:btnCats]</a>
  <a class="btn left" href="..">[const:btnList]</a>
  [case:[special:canpost]| |<a class="btn left" href="!post">[const:btnNewPost]</a>]
  <span class="spacer"></span>
  [case:[special:isadmin] | |
    <a class="btn right" href="/!settings[special:urltag]">[const:btnSettings]</a>
    <a class="btn right" href="/!sqlite">[const:btnConsole]</a>
  ]
</div>
<h1 class="thread_caption">
[caption]
<div class="spacer"></div>
[case:[special:canedit]||<a href="!edit_thread" title="[const:ttlEditThread]"><svg version="1.1" viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg">
  <title>[const:ttlEditThread]</title>
  <path d="m19.2 6.7c-.835-.84-2.2-.84-3.02 0l-.755.76-10.6 10.6.00273.0027-.334.335s-1.06 1.07-3.45
           8.85l-.125.19c-.0436.19-.0854.381-.129.381-.0398.19-.0778.381-.118.381l-.0987.381c-.0761.255-.153.514-.231.782-.173.588-.594
           1.92-.117 2.4.459.461 1.79.0556 2.37-.118.264-.0788.522-.156.774-.232.116-.0352.23-.0697.343-.105.122-.0373.245-.0744.362-.111.151-.0464.3-.0921.444-.138.0435-.0135.0861-.027.129-.0404
           7.38-2.3 8.71-3.39 8.8-3.48.000833-.000594.000833-.000594.0014-.0012.0046-.0044.0078-.0072.0078-.0072l.342-.345.023.023
           10.6-10.6-.000118-.000119.755-.76c.835-.84.835-2.21 0-3.03l-6.05-6.07zm-6.87
           19.4c-.0093.0063-.0218.0145-.0351.023-.0073.0047-.0162.0103-.025.0158-.0089.0055-.0186.0116-.0288.0179-.0091.0055-.0186.0112-.0288.0175-.353.211-1.39.758-3.89
           1.67-.292.106-.611.219-.947.335l-3.57-3.58c.116-.339.23-.661.336-.956.907-2.51 1.45-3.58
           1.66-3.92.0051-.0084.00973-.0162.0143-.0238.00734-.0122.0142-.0234.0207-.0339.0051-.0082.0104-.0168.0149-.0238.00842-.0131.0166-.0259.023-.0352l.262-.263 6.47
           6.49-.268.268zm19-19.4-6.05-6.07c-.835-.84-2.2-.84-3.02 0l-1.42 1.51c-.835.84-.835 2.21 0 3.03l6.05 6.07c.835.84 2.2.84 3.02 0l1.51-1.52c.835-.84.835-2.21 0-3.03z"
        style="clip-rule:evenodd;fill-rule:evenodd"
  />
</svg></a>]
[case:[special:limited]|<a href="!feed" title="[const:rssfeed]">
<svg version="1.1" viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg">
 <title>RSS</title>
 <path d="m8.8 27.6c0 2.43-1.97 4.4-4.4 4.4s-4.4-1.97-4.4-4.4 1.97-4.4 4.4-4.4 4.4 1.97 4.4 4.4z"/>
 <path d="m21.2 32h-6.2c0-8.2-6.8-15-15-15v-6.2c11.8 0 21.2 9.4 21.2 21.2z"/>
 <path d="m25.6 32c0-14.2-11.4-25.6-25.6-25.6v-6.4c17.6 0 32 14.4 32 32z"/>
</svg></a>|]
</h1>

<ul class="thread_tags">[special:threadtags=[id]]</ul>