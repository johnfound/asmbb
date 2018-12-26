PRAGMA foreign_keys;
PRAGMA foreign_keys = OFF;
PRAGMA foreign_keys;

begin transaction;

create table Tags2 (
  Tag         text primary key,
  Importance  integer not null default 0,
  cnt         integer not null default 0,
  Description text
);

insert into Tags2(tag, importance, Description, cnt)
select tag, importance, Description, (select count() from threadtags tt where tt.tag = tag) from tags;

select count() from Tags2;
select count() from Tags;

drop table Tags;

select count() from ThreadTags;

alter table Tags2 rename to Tags;

create index idxTagImportance on Tags(Importance desc);
create index idxTagsTagImp on Tags(tag, importance desc);

CREATE TRIGGER ThreadTagsAI AFTER INSERT ON ThreadTags BEGIN
  update tags set cnt = cnt + 1 where tag = new.tag;
END;

CREATE TRIGGER ThreadTagsAD AFTER DELETE ON ThreadTags BEGIN
  update tags set cnt = cnt - 1 where tag = old.tag;
END;

CREATE TRIGGER ThreadTagsAU AFTER UPDATE OF tag ON ThreadTags BEGIN
  update tags set cnt = cnt - 1 where tag = old.tag;
  update tags set cnt = cnt + 1 where tag = new.tag;
END;


PRAGMA foreign_key_check;

rollback;

PRAGMA foreign_keys = ON;
PRAGMA foreign_keys;
