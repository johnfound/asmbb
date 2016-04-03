<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>FastCGI in assembly language</title>
  <link rel="stylesheet" href="/all.css">
</head>

<body>
  <div class="header">
    <div class="login_interface">
      [case:[special:userid]|<a href="/login/">Login</a><br><a href="/register/">Register</a>|
      <a href="/logout/">Logout ( [special:username] )</a><br><a href="/userinfo/[special:userid]">User profile</a>]
    </div>
    <form class="tags" id="search_form" action="/search" method="get" >
      <input id="search_line" type="edit" size="40" name="s" placeholder="search" value="[special:search]"><input id="search_btn"  type="submit" value="" >
    </form>
    <h1>AsmBB demo</h1>
  </div>

<div class="tags"><a class="taglink" title="Show all threads" href="/list/"><img src="/images/posts.svg" alt="All"></a>[special:alltags]</div>