[css:common.css]
[css:login.css]

<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>Crypto protection</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    [special:allstyles]
  </head>

  <body>
    <form class="login-block" method="post" target="_self" action="/">
      <h1>Encrypted database!</h1>
      <p class="pi_pass"><input type="password" value="" placeholder="Password" name="initpass" class="password" maxlength="1024" autocomplete="off" autofocus></p>
      <p class="pi_pass"><input type="text" value="" placeholder="Page size (default is 4096 bytes)" name="pagesize" class="number" maxlength="1024" autocomplete="off"></p>
      <input type="image" name="submit" id="submit" value="Submit"><label class="submit" for="submit">Decrypt</label>
    </form>
  </body>
</html>