ATTACH "./NewBoard.sqlite" as Backup;

BEGIN TRANSACTION;



delete from Params;
insert into New.Params (id, val) select id, val from Old.Params;






















COMMIT;
