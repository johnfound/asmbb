[css:navigation.css]
[css:posts.css]
[css:markdown.css]

[case:[special:lang]|
  [equ:btnList=Threads]
  [equ:btnNewPost=Answer]
  [equ:ttlEditThread=Edit the thread attributes.]
|
  [equ:btnList=Теми]
  [equ:btnNewPost=Отговор]
  [equ:ttlEditThread=Редактиране на атрибутите на темата.]
|
  [equ:btnList=Темы]
  [equ:btnNewPost=Ответить]
  [equ:ttlEditThread=Редакция атрибутов темы]
|
  [equ:btnList=Liste des sujets]
  [equ:btnNewPost=Répondre]
  [equ:ttlEditThread=Éditer le titre du sujet et les mots-clés.]
|
  [equ:btnList=Themen]
  [equ:btnNewPost=Antworten]
  [equ:ttlEditThread=Themenoptionen ändern.]
]

[css:highlight.css]

<script src="[special:skin]/highlight.js"></script>
<script>
document.addEventListener('DOMContentLoaded', (event) => {
  document.querySelectorAll('pre>code').forEach((block) => {
    hljs.highlightBlock(block);
  });
});
</script>

<h1 class="thread_caption">
[caption]
[case:[special:canedit]||<a href="!edit_thread" title="[const:ttlEditThread]" class="btn img-btn">
  <svg version="1.1" width="16" height="16" viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg">
    <path d="m19 4-14 14-5 14 14-5 14-14-9-9zm-13 16.4 5.6 5.6-5.6 2-2-2 2-5.6z"/>
    <path d="m20 3 9 9 3-3-9-9z"/>
  </svg>
</a>]
</h1>
<ul class="thread_tags">[special:threadtags=[id]]</ul>

<div class="navigation3 btn-bar">
  <a class="btn" href="..">[const:btnList]</a>
  [case:[special:canpost]| |<a class="btn" href="!post">[const:btnNewPost]</a>]
</div>
