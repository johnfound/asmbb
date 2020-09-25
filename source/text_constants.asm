
struc mtext [langstr] {
common
  label . dword
forward
  local ofs, lang
  dd  ofs, lang
forward
  match l=:t,langstr \{
    lang = `l
    ofs db t
        dd 0
  \}
}



cUsersOnlineTitle       mtext   EN: "Online Users",             \
                                BG: "Активни потребители",      \
                                RU: "Активные потребители",     \
                                FR: "Utilisateurs en ligne",    \
                                DE: "Benutzer online"

cPostDeleteTitle        mtext   EN: "Delete confirmation",       \
                                BG: "Потвърждаване на изтриване",\
                                RU: "Подтверждение удаления",    \
                                FR: "Confirmer la suppression",  \
                                DE: "Löschbestätigung"

cPostRestoreTitle       mtext   EN: "Restore to old version", \
                                BG: "Възстановяване до предна версия",\
                                RU: "Восстановить предыдущую версию", \
                                FR: "Restaurer l’ancienne version",\
                                DE: "Auf alte Version zurücksetzen"

cHistoryTitle           mtext   EN: "Post edition history",     \
                                BG: "История на редакциите",    \
                                RU: "История редакции",         \
                                FR: "Historique d’édition",     \
                                DE: "Beitragsbearbeitungsverlauf"


cForumSettingsTitle     mtext   EN: "Forum settings page",      \
                                BG: "Настройки на форума",      \
                                RU: "Настройки форума",         \
                                FR: "Paramètres du forum",      \
                                DE: "Einstellungsseite"

cPostingInTitle         mtext   EN: "Posting in: ",             \
                                BG: "Публикация в: ",           \
                                RU: "Написать в: ",             \
                                FR: "Posté dans :",             \
                                DE: "Schreibe Beitrag in: "


cSearchResultsTitle     mtext   EN: "Search results for: ",     \           ; Not used???
                                BG: "Резултати от търсенето на: ", \
                                RU: "Результаты поиска: ",      \
                                FR: "Résultats de la recherche :",\
                                DE: "Suchergebnisse für: "

cNewThreadTitle         mtext   EN: "New thread posting",       \
                                BG: "Нова тема",                \
                                RU: "Новая тема",               \
                                FR: "Poster un nouveau message",\
                                DE: "Neues Thema"

cLoginDialogTitle       mtext   EN: "Login",                    \
                                BG: "Включване",                \
                                RU: "Вход",                     \
                                FR: "Connexion",                \
                                DE: "Anmelden"

cUserProfileTitle       mtext   EN: "Profile for: ",            \
                                BG: "Потребителски профил: ",   \
                                RU: "Профиль потребителя: ",    \
                                FR: "Profil de :",              \
                                DE: "Profil von: "

cEditingPageTitle       mtext   EN: "Editing page: ",           \
                                BG: "Редактиране на: ",         \
                                RU: "Редактирование: ",         \
                                FR: "Éditer la page:",          \
                                DE: "Ändere Seite: "

cEditingThreadTitle     mtext   EN: "Editing thread: ",         \
                                BG: "Редактиране на тема: ",    \
                                RU: "Редактирование темы: ",    \
                                FR: "Éditer le sujet:",         \
                                DE: "Ändere Thema: "

cSQLiteConsoleTitle     mtext   EN: "WARNING! SQLite console. You can destroy your database here!",     \
                                BG: "ВНИМАНИЕ! SQLite конзола. От тук е възможно да повредите базата данни!",    \
                                RU: "ВНИМАНИЕ! Конзоль SQLite. Возможно повреждение базы данных!",      \
                                FR: "ATTENTION ! Console SQLite. Vous pouvez détruire votre base de données !", \
                                DE: "WARNUNG: SQLite-Konsole. Sie können hier Ihre Datenbank zerstören!"

cCreateAdminTitle       mtext   EN: "Create the admin account!",                \
                                BG: "Създаване на потребител администратор!",   \
                                RU: "Создание учетную запись администратора!",  \
                                FR: "Créer le compte administrateur !",         \
                                DE: "Erstellen Sie das Adminkonto!"

cThreadListTitle        mtext   EN: "Threads list ",    \
                                BG: "Теми ",            \
                                RU: "Темы ",            \
                                FR: "Liste des sujets", \
                                DE: "Liste der Themen "

cChatTitle              mtext   EN: "Chat ",            \
                                BG: "Чат ",             \
                                RU: "Чат ",             \
                                FR: "Tchat",            \
                                DE: "Chat"

cAnonName               mtext   EN: "Anon",             \
                                BG: "Анон",             \
                                RU: "Анон",             \
                                FR: "Anon",             \
                                DE: "Anon"

cEmptySearch            mtext   EN: "The search found nothing. Try other keywords.",                    \
                                BG: "Търсенето не намери нищо. Опитайте с други думи.",                 \
                                RU: "Поиск не нашел ничего. Попробуйте другой запрос.",                 \
                                FR: "La recherche n’a rien renvoyer. Essayer d’autres mots-clés.",      \
                                DE: "Die Suche lieferte keine Ergebnisse. Versuchen Sie es mit anderen Begriffen."

cActivityLogin          mtext   EN: " entered the forum.",      \
                                BG: " влезе във форума.",       \
                                RU: " вошел на форум.",         \
                                FR: " est entré dans le forum.",\
                                DE: " trat ins Forum ein."

cActivityLogout         mtext   EN: " logged out.",                     \
                                BG: " излезе от форума.",               \
                                RU: " вышел из форума.",                \
                                FR: " s'est déconnecté du forum.",      \
                                DE: " hat sich vom Forum abgemeldet."

cActivityRead           mtext   EN: " is reading thread ",      \
                                BG: " чете темата ",            \
                                RU: " читает ветку ",           \
                                FR: " parcours le sujet ",             \
                                DE: " liest das Thema "

cActivityList           mtext   EN: " is browsing the threads list.",    \
                                BG: " разглежда темите.",               \
                                RU: " просматривает список тем.",    \
                                FR: " navigue dans la liste des discussions.",    \
                                DE: " durchsucht die Threads-Liste."

cActivityChat           mtext   EN: " entered the chat.",               \
                                BG: " влезе в чата.",                   \
                                RU: " вошол в чат.",                    \
                                FR: " est entré dans le chat.",         \
                                DE: " hat den Chat betreten."

cActivityNewPost        mtext   EN: " wrote a new post. ",              \
                                BG: " написа мнение. ",                  \
                                RU: " написал мнение. ",                 \
                                FR: " wrote a new post. ",              \
                                DE: " wrote a new post. "
