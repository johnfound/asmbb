[css:sqlite.css]

[case:[special:lang]|
  [equ:ttlStmt=SQL statement]
  [equ:btnExec=Exec]
  [equ:btnRevert=Revert]
|
  [equ:ttlStmt=SQL команди]
  [equ:btnExec=Изпълни]
  [equ:btnRevert=Отказ]
|
  [equ:ttlStmt=SQL команды]
  [equ:btnExec=Выполнить]
  [equ:btnRevert=Отказ]
|
  [equ:ttlStmt=SQL statement]
  [equ:btnExec=Exec]
  [equ:btnRevert=Revert]
|
  [equ:ttlStmt=SQL-Statement]
  [equ:btnExec=Ausführen]
  [equ:btnRevert=Zurücksetzen]
]

<div class="console">
  <form id="editform" action="/!sqlite/#sql_result" method="post">
    <p>[const:ttlStmt]:</p>
    <textarea id="source" name="source" placeholder="SQL">[source]</textarea>
    <div class="btn-bar">
      <a id="sql_result" style="visibility: hidden; margin: 0px; padding: 0px;"></a>
      <button class="btn" type="submit">[const:btnExec]</button>
      <button class="btn" type="reset">[const:btnRevert]</button>
      <input type="hidden" name="ticket" value="[Ticket]" >
    </div>
  </form>
</div>
[html:[result]]
