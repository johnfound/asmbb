[css:userslist.css]

[case:[special:lang]|
  [equ:hUser=User name]
  [equ:hAvatar=Avatar]
  [equ:hTheme=Theme]
  [equ:hCnt=Post count]
  [equ:hReg=Registered]
  [equ:hSeen=Last seen]
|
  [equ:hUser=Участник]
  [equ:hAvatar=Снимка]
  [equ:hTheme=Тема]
  [equ:hCnt=Брой постове]
  [equ:hReg=Регистриран на]
  [equ:hSeen=Последно влизал]
|
  [equ:hUser=Участник]
  [equ:hAvatar=Аватар]
  [equ:hTheme=Тема]
  [equ:hCnt=Посты]
  [equ:hReg=Регистрация]
  [equ:hSeen=Последний вход]
|
  [equ:hUser=Utilisateur]
  [equ:hAvatar=Avatar]
  [equ:hTheme=Thème]
  [equ:hCnt=Nombre de messages]
  [equ:hReg=Date d'inscription]
  [equ:hSeen=Dernière connexion]
|
  [equ:hUser=Benutzer]
  [equ:hAvatar=Avatar]
  [equ:hTheme=Theme]
  [equ:hCnt=Beiträge]
  [equ:hReg=Registriert]
  [equ:hSeen=Zuletzt gesehen]
]

<div class="ui">
  <form method="GET">
    <select name="sort" onchange="this.form.submit()">
      <option value="0" [case:[special:order]|selected|]>Sort: (Default)</option>
      <option value="1" [case:[special:order]||selected|]>[const:hUser] ▲</option>
      <option value="2" [case:[special:order]|||selected|]>[const:hUser] ▼</option>
      <option value="8" [case:[special:order]|||||||||selected|]>[const:hCnt] ▼</option>
      <option value="7" [case:[special:order]||||||||selected|]>[const:hCnt] ▲</option>
      <option value="4" [case:[special:order]|||||selected|]>[const:hAvatar]</option>
      <option value="5" [case:[special:order]||||||selected|]>[const:hTheme] ▲</option>
      <option value="6" [case:[special:order]|||||||selected|]>[const:hTheme] ▼</option>
      <option value="9" [case:[special:order]||||||||||selected|]>[const:hReg] ▲</option>
     <option value="10" [case:[special:order]|||||||||||selected|]>[const:hReg] ▼</option>
     <option value="11" [case:[special:order]||||||||||||selected|]>[const:hSeen] ▲</option>
     <option value="12" [case:[special:order]|||||||||||||selected|]>[const:hSeen] ▼</option>

  <!----    <option value="3" [case:[special:order]||||selected|]>[const:hAvatar] ▲</option> ---->
    </select>
    <noscript>
    <input  class="btn" type="submit" value="Sort">
    </noscript>
  </form>
</div>