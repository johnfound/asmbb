[css:navigation.css]
[css:sqlite.css]

[case:[special:lang]|
  [equ:btnList=Thread list]
  [equ:btnSettings=Settings]
  [equ:btnSQL=SQL console]
  [equ:ttlName=Script name]
  [equ:phScript=Script name]
  [equ:altEdit=Edit]
  [equ:altSave=Save]
  [equ:altDel=Delete]
  [equ:ttlStmt=SQL statement]
  [equ:btnExec=Exec]
  [equ:btnRevert=Revert]
|
  [equ:btnList=Списък теми]
  [equ:btnSettings=Настройки]
  [equ:btnSQL=SQL конзола]
  [equ:ttlName=Име на скрипта]
  [equ:phScript=Име на скрипта]
  [equ:altEdit=Редактиране]
  [equ:altSave=Запис]
  [equ:altDel=Изтриване]
  [equ:ttlStmt=SQL команди]
  [equ:btnExec=Изпълни]
  [equ:btnRevert=Отказ]
|
  [equ:btnList=Список тем]
  [equ:btnSettings=Настройки]
  [equ:btnSQL=SQL конзоль]
  [equ:ttlName=Имя скрипта]
  [equ:phScript=Имя скрипта]
  [equ:altEdit=Редактировать]
  [equ:altSave=Записать]
  [equ:altDel=Удалить]
  [equ:ttlStmt=SQL команды]
  [equ:btnExec=Выполнить]
  [equ:btnRevert=Отказ]
|
  [equ:btnList=Liste des sujets]
  [equ:btnSettings=Paramètres]
  [equ:btnSQL=Console SQL]
  [equ:ttlName=Nom du script]
  [equ:phScript=Nom du script]
  [equ:altEdit=Éditer]
  [equ:altSave=Enregistrer]
  [equ:altDel=Supprimer]
  [equ:ttlStmt=SQL statement]
  [equ:btnExec=Exec]
  [equ:btnRevert=Revert]
|
  [equ:btnList=Liste der Themen]
  [equ:btnSettings=Einstellungen]
  [equ:btnSQL=SQL-Konsole]
  [equ:ttlName=Scriptname]
  [equ:phScript=Scriptname]
  [equ:altEdit=Ändern]
  [equ:altSave=Speichern]
  [equ:altDel=Löschen]
  [equ:ttlStmt=SQL-Statement]
  [equ:btnExec=Ausführen]
  [equ:btnRevert=Zurücksetzen]
]

<div class="console">
  <div class="ui">
    <a class="ui left" href="/">[const:btnList]</a>
    <span class="spacer"></span>
    <a class="ui right" href="/!settings">[const:btnSettings]</a>
    <a class="ui right" target="_blank" href="/!sqlite">[const:btnSQL]</a>
  </div>
  <form id="editform" action="/!sqlite/#sql_result" method="post">
    <p>[const:ttlName]:</p>
    <div class="toolbar">
      <input class="title" size="40" type="edit" value="" placeholder="[const:phScript]" name="name">
      <a class="button" href="/"><img src="[special:skin]/_images/edit_white.svg" alt="[const:altEdit]"></a>
      <a class="button" href="/"><img src="[special:skin]/_images/save_white.svg" alt="[const:altSave]"></a>
      <a class="button" href="/"><img src="[special:skin]/_images/del_white.svg" alt="[const:altDel]"></a>
    </div>
    <p>[const:ttlStmt]:</p>
    <textarea class="sql_editor" name="source" id="source"  placeholder="SQL">[source]</textarea>
    <div class="panel">
      <a id="sql_result" style="visibility: hidden; margin: 0px; padding: 0px;"></a>
      <input type="submit" value="[const:btnExec]" >
      <input type="reset" value="[const:btnRevert]" >
      <input type="hidden" name="ticket" value="[Ticket]" >
    </div>
  </form>
</div>
[html:[result]]
