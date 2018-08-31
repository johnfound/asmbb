drop table Tags2;
drop table ThreadTags2;

create table Tags2 (
  Tag         text primary key,
  Importance  integer not null default 0,
  Description text,
  Count       integer not null default 0
);

create index idxTag2Importance on Tags2(Importance desc);
create index idxTags2TagImp on Tags2(tag, importance desc);


create table ThreadTags2 (
  ThreadID integer references Threads(id) on delete cascade,
  Tag      text references Tags2(Tag) on delete cascade on update cascade
);

create unique index idxThreadTags2Unique on ThreadTags2 ( ThreadID, Tag );
create index idxThreadsTags2Tags on ThreadTags2 (Tag);

CREATE TRIGGER TagsAI AFTER INSERT ON ThreadTags2 BEGIN
  update Tags2 set Count = Count + 1 where Tags2.Tag = new.Tag;
END;

CREATE TRIGGER TagsAD AFTER DELETE ON ThreadTags2 BEGIN
  update Tags2 set Count = Count - 1 where Tags2.Tag = old.Tag;
END;

CREATE TRIGGER TagsAU AFTER UPDATE ON ThreadTags2 BEGIN
  update Tags2 set Count = Count + 1 where Tags2.Tag = new.Tag;
  update Tags2 set Count = Count - 1 where Tags2.Tag = old.Tag;
END;


insert into Tags2(tag, description, importance) select Tag, Description, Importance from Tags;
insert into ThreadTags2(ThreadID, Tag) select ThreadID, Tag from ThreadTags;
